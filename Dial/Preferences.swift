import SwiftUI
import Observation

@Observable final class Preferences {
    enum Appearance: String, CaseIterable, Identifiable {
        case system = "System", light = "Light", dark = "Dark"
        var id: String { rawValue }
        var scheme: ColorScheme? {
            switch self { case .system: nil; case .light: .light; case .dark: .dark }
        }
    }
    enum Layout: String {
        case grid, list
    }
    enum Narration: String, CaseIterable, Identifiable {
        case off = "Off", headphones = "Headphones & Bluetooth", always = "Always"
        var id: String { rawValue }
    }
    var hapticsEnabled: Bool { didSet { defaults.set(hapticsEnabled, forKey: "hapticsEnabled") } }
    var keepAwakeWhileCharging: Bool { didSet { defaults.set(keepAwakeWhileCharging, forKey: "keepAwakeWhileCharging") } }
    var narration: Narration { didSet { defaults.set(narration.rawValue, forKey: "narration") } }
    var narrationVoiceID: String { didSet { defaults.set(narrationVoiceID, forKey: "narrationVoiceID") } }
    var autoplayOnOpen: Bool { didSet { defaults.set(autoplayOnOpen, forKey: "autoplayOnOpen") } }
    var appearance: Appearance { didSet { defaults.set(appearance.rawValue, forKey: "appearance") } }
    var layout: Layout { didSet { defaults.set(layout.rawValue, forKey: "stationLayout") } }
    @ObservationIgnored private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hapticsEnabled = defaults.object(forKey: "hapticsEnabled") as? Bool ?? true
        keepAwakeWhileCharging = defaults.bool(forKey: "keepAwakeWhileCharging")
        narration = Narration(rawValue: defaults.string(forKey: "narration") ?? "") ?? .off
        narrationVoiceID = defaults.string(forKey: "narrationVoiceID") ?? ""
        autoplayOnOpen = defaults.object(forKey: "autoplayOnOpen") as? Bool ?? true
        appearance = Appearance(rawValue: defaults.string(forKey: "appearance") ?? "") ?? .system
        layout = Layout(rawValue: defaults.string(forKey: "stationLayout") ?? "") ?? .grid
    }
}

@MainActor @Observable final class SleepTimer {
    private(set) var deadline: Date?
    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored var onExpire: (() -> Void)?

    func start(seconds: TimeInterval, now: Date = .now) {
        cancel()
        deadline = now.addingTimeInterval(seconds)
        task = Task { [weak self] in
            try? await Task.sleep(for: .seconds(max(0, seconds)))
            guard !Task.isCancelled else { return }
            self?.expireIfNeeded()
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
        deadline = nil
    }

    @discardableResult func expireIfNeeded(now: Date = .now) -> Bool {
        guard let deadline, now >= deadline else { return false }
        cancel()
        onExpire?()
        return true
    }
}
