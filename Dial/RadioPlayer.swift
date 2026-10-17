import AVFoundation
import MediaPlayer
import Observation
import Network

@MainActor @Observable
final class RadioPlayer {
    enum State: Equatable {
        case idle, connecting, playing, paused, failed
    }

    let library: Library
    let preferences: Preferences
    let sleepTimer = SleepTimer()
    let savedItems: SavedItems
    let alarms: StationAlarms
    @ObservationIgnored private let listeningBehavior = ListeningBehavior()
    @ObservationIgnored private let narrator = StationNarrator()
    @ObservationIgnored private var isForeground = false
    private(set) var liveTitle: String?
    private(set) var externalCommandSequence = 0
    @ObservationIgnored private var metadataDelegate: StreamMetadata?
    @ObservationIgnored private let pathMonitor = NWPathMonitor()
    @ObservationIgnored private var networkWasLost = false
    @ObservationIgnored private var retryTask: Task<Void, Never>?
    @ObservationIgnored private var retryCount = 0
    @ObservationIgnored private var sleepExpired = false
    private(set) var state: State = .idle
    var volume: Double = 0.7 {
        didSet {
            applyPlayerVolume()
            if state == .connecting && tuningSoundEnabled { tuningNoise.start(volume: volume) }
        }
    }
    var tuningSoundEnabled: Bool {
        didSet {
            soundDefaults.set(tuningSoundEnabled, forKey: "tuningSoundEnabled")
            if !tuningSoundEnabled { tuningNoise.stop(immediately: true) }
            else if state == .connecting { tuningNoise.start(volume: volume) }
        }
    }
    @ObservationIgnored private let player = AVPlayer()
    @ObservationIgnored private let tuningNoise = TuningNoise()
    @ObservationIgnored private let soundDefaults: UserDefaults
    @ObservationIgnored private var itemObservation: NSKeyValueObservation?
    @ObservationIgnored private var transportObservation: NSKeyValueObservation?
    @ObservationIgnored private var timeout: Task<Void, Never>?
    @ObservationIgnored private var notificationTokens: [NSObjectProtocol] = []
    @ObservationIgnored private var remoteTargets: [(MPRemoteCommand, Any)] = []
    @ObservationIgnored private var loadedID: String?
    @ObservationIgnored private var wantsPlayback = false
    @ObservationIgnored private var resumeAfterInterruption = false
    @ObservationIgnored private var autoplayOnActivation = true
    @ObservationIgnored private let streamOverride: URL?

    var isActive: Bool { state == .playing || state == .connecting }
    var selected: Station { library.selected }

    init(library: Library, streamOverride: URL? = nil, defaults: UserDefaults = .standard) {
        self.library = library
        self.savedItems = SavedItems(defaults: defaults)
        self.alarms = StationAlarms(defaults: defaults)
        self.preferences = Preferences(defaults: defaults)
        self.streamOverride = streamOverride
        self.soundDefaults = defaults
        self.tuningSoundEnabled = defaults.object(forKey: "tuningSoundEnabled") as? Bool ?? true
        player.volume = Float(volume)
        narrator.onSpeakingChanged = { [weak self] in self?.applyPlayerVolume() }
        transportObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] _, _ in
            Task { @MainActor in self?.updateTransport() }
        }
        sleepTimer.onExpire = { [weak self] in
            guard let self else { return }
            self.pause()
            self.sleepExpired = true
            self.autoplayOnActivation = false
        }
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self else { return }
                if path.status != .satisfied {
                    self.networkWasLost = true
                } else if self.networkWasLost {
                    self.networkWasLost = false
                    if self.wantsPlayback && self.state != .playing { self.play() }
                }
            }
        }
        pathMonitor.start(queue: DispatchQueue(label: "Dial.network"))
        configureRemoteCommands()

        #if os(iOS)
        notificationTokens.append(NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification, object: nil, queue: .main
        ) { [weak self] notification in
            let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
            let options = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            Task { @MainActor in
                guard let self else { return }
                if type == AVAudioSession.InterruptionType.began.rawValue {
                    let shouldResume = self.wantsPlayback
                    self.pause()
                    self.resumeAfterInterruption = shouldResume
                } else if self.resumeAfterInterruption,
                          AVAudioSession.InterruptionOptions(rawValue: options).contains(.shouldResume) {
                    self.resumeAfterInterruption = false
                    self.play()
                }
            }
        })
        notificationTokens.append(NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main
        ) { [weak self] notification in
            let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt
            if reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue {
                Task { @MainActor in self?.pause() }
            }
        })
        #endif
        notificationTokens.append(NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime, object: nil, queue: .main
        ) { [weak self] notification in
            guard let failedItem = notification.object as? AVPlayerItem else { return }
            Task { @MainActor in
                guard let self, self.player.currentItem === failedItem else { return }
                self.fail()
            }
        })
    }

    func select(_ station: Station, autoplay: Bool? = nil) {
        let shouldPlay = autoplay ?? (wantsPlayback && state != .failed)
        guard station != selected else {
            if shouldPlay && !isActive { play() }
            return
        }
        narrator.stop()
        wantsPlayback = false
        retryTask?.cancel()
        liveTitle = nil
        metadataDelegate = nil
        timeout?.cancel()
        player.pause()
        tuningNoise.stop(immediately: true)
        itemObservation = nil
        player.replaceCurrentItem(with: nil)
        loadedID = nil
        library.select(station)
        state = .idle
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        if shouldPlay {
            play()
            if isActive { narrator.announce(station.name, mode: preferences.narration, voiceID: preferences.narrationVoiceID, volume: volume) }
        }
    }

    func seek(_ direction: Int) { select(library.adjacent(direction)) }

    func selectRegion(_ region: RadioRegion) {
        guard let station = library.preferredStation(in: region) else { return }
        select(station, autoplay: true)
    }

    func selectBand(_ band: RadioBand) {
        guard let station = library.preferredStation(band: band) else { return }
        select(station, autoplay: true)
    }

    func enteredBackground() {
        autoplayOnActivation = true
        isForeground = false
        refreshListeningBehavior()
    }

    func becameActive() {
        isForeground = true
        refreshListeningBehavior()
        alarms.refresh()
        if sleepTimer.expireIfNeeded() || sleepExpired { return }
        guard autoplayOnActivation else { return }
        autoplayOnActivation = false
        if preferences.autoplayOnOpen && !isActive { play() }
    }

    func toggle() {
        if isActive { pause() } else { play() }
    }

    func play() {
        sleepExpired = false
        retryCount = 0
        retryTask?.cancel()
        beginPlayback()
    }

    private func beginPlayback() {

        #if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio)
            try session.setActive(true)
        } catch {
            fail()
            return
        }
        #endif
        wantsPlayback = true
        state = .connecting
        if tuningSoundEnabled { tuningNoise.start(volume: volume) }
        if loadedID != selected.id || player.currentItem?.status == .failed {
            let item = AVPlayerItem(url: streamOverride ?? selected.streamURL)
            let output = AVPlayerItemMetadataOutput(identifiers: nil)
            let delegate = StreamMetadata { [weak self, weak item] title in
                guard let self, let item, self.player.currentItem === item, self.wantsPlayback else { return }
                self.liveTitle = title
                self.updateNowPlaying()
            }
            metadataDelegate = delegate
            output.setDelegate(delegate, queue: .main)
            item.add(output)

            itemObservation = item.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
                Task { @MainActor in
                    guard let self, self.player.currentItem === item else { return }
                    if item.status == .failed { self.fail() }
                }
            }
            player.replaceCurrentItem(with: item)
            loadedID = selected.id
        }
        player.play()
        updateNowPlaying()
        scheduleTimeout()
    }

    private func scheduleTimeout() {
        timeout?.cancel()
        timeout = Task { [weak self] in
            try? await Task.sleep(for: .seconds(20))
            guard !Task.isCancelled, let self, self.state == .connecting else { return }
            self.fail()
        }
    }

    func pause() {
        narrator.stop()
        wantsPlayback = false
        resumeAfterInterruption = false
        retryTask?.cancel()
        liveTitle = nil
        metadataDelegate = nil
        timeout?.cancel()
        player.pause()
        // A radio resumes at the live feed, never at previously buffered audio.
        itemObservation = nil
        player.replaceCurrentItem(with: nil)
        loadedID = nil
        tuningNoise.stop(immediately: true)
        state = .paused
        updateNowPlaying()
    }

    private func fail() {
        narrator.stop()
        timeout?.cancel()
        player.pause()
        itemObservation = nil
        player.replaceCurrentItem(with: nil)
        metadataDelegate = nil
        liveTitle = nil
        loadedID = nil
        tuningNoise.stop(immediately: true)
        if wantsPlayback && retryCount < 2 {
            retryCount += 1
            state = .connecting
            let delay = retryCount == 1 ? 1.0 : 3.0
            retryTask?.cancel()
            retryTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled, let self, self.wantsPlayback else { return }
                self.beginPlayback()
            }
        } else {
            state = .failed
            // Keep intent for recovery after an actual network outage. Pause
            // and the sleep timer explicitly clear it.
        }
        updateNowPlaying()
    }

    private func updateTransport() {
        guard wantsPlayback else { return }
        switch player.timeControlStatus {
        case .playing:
            state = .playing
            timeout?.cancel()
            tuningNoise.stop()
        case .waitingToPlayAtSpecifiedRate:
            if state != .connecting { scheduleTimeout() }
            state = .connecting
            if tuningSoundEnabled { tuningNoise.start(volume: volume) }
        case .paused:
            break
        @unknown default:
            break
        }
        updateNowPlaying()
    }

    @discardableResult
    func handleCommand(_ action: PlaybackCommand.Action) -> Bool {
        autoplayOnActivation = false
        switch action {
        case .station(let id):
            guard let station = library.stations.first(where: { $0.id == id }) else { return false }
            select(station, autoplay: true)
        case .resume:
            play()
        case .pause:
            pause()
        }
        externalCommandSequence += 1
        return true
    }

    func refreshListeningBehavior() {
        listeningBehavior.update(enabled: preferences.keepAwakeWhileCharging, isActive: isForeground)
    }

    func narrationPreferenceChanged() {
        if preferences.narration == .off { narrator.stop() }
    }

    private func applyPlayerVolume() {
        player.volume = Float(volume * (narrator.isSpeaking ? 0.3 : 1))
    }

    private func updateNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: liveTitle ?? selected.name,
            MPMediaItemPropertyArtist: "\(selected.name) · \(selected.frequencyLabel) · \(selected.city)",
            MPNowPlayingInfoPropertyIsLiveStream: true,
            MPNowPlayingInfoPropertyPlaybackRate: state == .playing ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]
        #if os(macOS)
        // macOS's Now Playing widget reads the state separately from the info dictionary.
        MPNowPlayingInfoCenter.default().playbackState = state == .playing ? .playing : .paused
        #endif
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        let bindings: [(MPRemoteCommand, @MainActor () -> Void)] = [
            (center.playCommand, { [weak self] in self?.play() }),
            (center.pauseCommand, { [weak self] in self?.pause() }),
            (center.togglePlayPauseCommand, { [weak self] in self?.toggle() }),
            (center.nextTrackCommand, { [weak self] in self?.seek(1) }),
            (center.previousTrackCommand, { [weak self] in self?.seek(-1) })
        ]
        for (command, action) in bindings {
            command.isEnabled = true
            let target = command.addTarget { _ in
                Task { @MainActor in action() }
                return .success
            }
            remoteTargets.append((command, target))
        }
        center.changePlaybackPositionCommand.isEnabled = false
    }
}
