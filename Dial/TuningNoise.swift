import AVFoundation

/// A quiet, synthesized radio-static loop used only while a live stream connects.
@MainActor
final class TuningNoise {
    private let audio: AVAudioPlayer?
    private var fadeTask: Task<Void, Never>?

    init(bundle: Bundle = .main) {
        if let url = bundle.url(forResource: "tuning-static", withExtension: "wav") {
            audio = try? AVAudioPlayer(contentsOf: url)
            audio?.numberOfLoops = -1
            audio?.prepareToPlay()
        } else {
            audio = nil
        }
    }

    var isPlaying: Bool { audio?.isPlaying ?? false }

    func start(volume: Double) {
        fadeTask?.cancel()
        guard let audio else { return }
        if !audio.isPlaying {
            audio.volume = 0
            audio.play()
        }
        audio.setVolume(Float(volume) * 0.28, fadeDuration: 0.07)
    }

    func stop(immediately: Bool = false) {
        fadeTask?.cancel()
        guard let audio else { return }
        if immediately {
            audio.stop()
            audio.volume = 0
            return
        }
        audio.setVolume(0, fadeDuration: 0.15)
        fadeTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(160))
            guard !Task.isCancelled else { return }
            self?.audio?.stop()
        }
    }
}
