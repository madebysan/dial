import AVFoundation
#if os(iOS)
import UIKit
#else
import CoreAudio
#endif

/// Keeps the screen awake while charging. iPhone-only: a Mac's display sleep follows its own energy settings.
@MainActor
final class ListeningBehavior {
    #if os(iOS)
    private var enabled = false
    private var isActive = false
    private var batteryObserver: NSObjectProtocol?

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    deinit {
        if let batteryObserver { NotificationCenter.default.removeObserver(batteryObserver) }
    }

    nonisolated static func shouldKeepAwake(enabled: Bool, isActive: Bool, batteryState: UIDevice.BatteryState) -> Bool {
        enabled && isActive && (batteryState == .charging || batteryState == .full)
    }

    func update(enabled: Bool, isActive: Bool) {
        self.enabled = enabled
        self.isActive = isActive
        refresh()
    }

    private func refresh() {
        UIApplication.shared.isIdleTimerDisabled = Self.shouldKeepAwake(
            enabled: enabled, isActive: isActive, batteryState: UIDevice.current.batteryState)
    }
    #else
    func update(enabled: Bool, isActive: Bool) {}
    #endif
}

@MainActor
final class StationNarrator: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var current: AVSpeechUtterance?
    private(set) var isSpeaking = false
    var onSpeakingChanged: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    static func shouldAnnounce(mode: Preferences.Narration, headphones: Bool, voiceOver: Bool) -> Bool {
        !voiceOver && (mode == .always || (mode == .headphones && headphones))
    }

    func announce(_ stationName: String, mode: Preferences.Narration, voiceID: String, volume: Double) {
        guard Self.shouldAnnounce(mode: mode, headphones: Self.headphonesConnected,
                                  voiceOver: Platform.isVoiceOverRunning) else { return }
        stop()
        let utterance = AVSpeechUtterance(string: stationName)
        utterance.volume = Float(max(0, min(1, volume)))
        if !voiceID.isEmpty { utterance.voice = AVSpeechSynthesisVoice(identifier: voiceID) }
        current = utterance
        isSpeaking = true
        onSpeakingChanged?()
        synthesizer.speak(utterance)
    }

    private static var headphonesConnected: Bool {
        #if os(iOS)
        let headphonePorts: Set<AVAudioSession.Port> = [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE]
        return AVAudioSession.sharedInstance().currentRoute.outputs.contains { headphonePorts.contains($0.portType) }
        #else
        // Bluetooth outputs count as headphones; wired ones report the built-in headphone data source.
        var device = AudioObjectID(kAudioObjectUnknown)
        guard read(AudioObjectID(kAudioObjectSystemObject), kAudioHardwarePropertyDefaultOutputDevice, into: &device),
              device != kAudioObjectUnknown else { return false }
        var transport: UInt32 = 0
        if read(device, kAudioDevicePropertyTransportType, into: &transport),
           transport == kAudioDeviceTransportTypeBluetooth || transport == kAudioDeviceTransportTypeBluetoothLE { return true }
        var source: UInt32 = 0
        return read(device, kAudioDevicePropertyDataSource, scope: kAudioDevicePropertyScopeOutput, into: &source)
            && source == 0x6864_706E // 'hdpn'
        #endif
    }

    #if os(macOS)
    private static func read<T: BitwiseCopyable>(_ object: AudioObjectID, _ selector: AudioObjectPropertySelector,
                                scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal, into value: inout T) -> Bool {
        var address = AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: kAudioObjectPropertyElementMain)
        var size = UInt32(MemoryLayout<T>.size)
        return AudioObjectGetPropertyData(object, &address, 0, nil, &size, &value) == noErr
    }
    #endif

    func stop() {
        current = nil
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        onSpeakingChanged?()
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in self?.finished(utterance) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in self?.finished(utterance) }
    }

    private func finished(_ utterance: AVSpeechUtterance) {
        guard current === utterance else { return }
        current = nil
        isSpeaking = false
        onSpeakingChanged?()
    }
}
