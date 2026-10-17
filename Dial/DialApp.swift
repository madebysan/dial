import SwiftUI
import AppIntents

@main
struct DialApp: App {
    @State private var radio: RadioPlayer
    @State private var commands = PlaybackCommands.shared
    @Environment(\.scenePhase) private var scenePhase

    init() {
        var defaults = UserDefaults.standard
        var overrideURL: URL?
        var stations = Station.sample
        var countryCode = Locale.current.region?.identifier
        var screenshotMode = false
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            countryCode = "US"
            if let override = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--initial-country=") }) {
                countryCode = String(override.dropFirst("--initial-country=".count))
            }
            let suite = "com.santiagoalonso.dial.uitests"
            defaults = UserDefaults(suiteName: suite)!
            if ProcessInfo.processInfo.arguments.contains("--reset-state") {
                // Cancel simulator test alarms before discarding their local IDs.
                let alarms = StationAlarms(defaults: defaults)
                for alarm in alarms.records { try? alarms.remove(alarm.id) }
                defaults.removePersistentDomain(forName: suite)
            }
        }
        if ProcessInfo.processInfo.arguments.contains("--seed-catalog") {
            let ids: Set<String> = ["wnyc", "wqxr", "wbgo", "wnyu", "wfuv", "wfmu", "futura", "diamante", "elpuente", "wabc", "clarin"]
            stations = stations.filter { ids.contains($0.id) }
        }
        // App Store screenshots: never autoplay, so the simulator can keep its normal volume icon in silence.
        if ProcessInfo.processInfo.arguments.contains("--screenshots") {
            screenshotMode = true
            defaults.set(false, forKey: "autoplayOnOpen")
        }
        if ProcessInfo.processInfo.arguments.contains("--fail-stream") {
            overrideURL = URL(string: "https://127.0.0.1:1/unavailable")
        }
        #endif
        let radio = RadioPlayer(library: Library(stations: stations, defaults: defaults, initialCountryCode: countryCode), streamOverride: overrideURL, defaults: defaults)
        #if targetEnvironment(simulator)
        // Keep Mac previews and automated stream checks silent.
        if !screenshotMode { radio.volume = 0 }
        #elseif DEBUG
        // Mac unit tests host the real app; keep them and `--muted` debug launches silent too.
        if ProcessInfo.processInfo.arguments.contains("--muted")
            || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { radio.volume = 0 }
        #endif
        _radio = State(initialValue: radio)
    }

    var body: some Scene {
        #if os(macOS)
        // A menu bar app (LSUIElement, no Dock icon): the player opens from the radio icon in the menu bar,
        // and the radio keeps playing when it closes. Quit is the power button in the player's top row.
        MenuBarExtra {
            player
        } label: {
            Image(systemName: radio.isActive ? "radio.fill" : "radio")
                .accessibilityLabel("Dial")
        }
        .menuBarExtraStyle(.window)
        .commands { PlaybackMenu(radio: radio) }
        #else
        WindowGroup { player }
        #endif
    }

    private var player: some View {
            RadioView(radio: radio)
                .tint(Palette.accent)
                .onChange(of: radio.preferences.keepAwakeWhileCharging) { _, _ in radio.refreshListeningBehavior() }
                .onChange(of: radio.preferences.narration) { _, _ in radio.narrationPreferenceChanged() }
                .onChange(of: commands.pending, initial: true) { _, request in
                    guard let request else { return }
                    radio.handleCommand(request.action)
                    commands.clear(request.id)
                }
                .onOpenURL { url in
                    if let action = PlaybackCommands.action(for: url) { radio.handleCommand(action) }
                }
                .onChange(of: radio.library.favoriteIDs) { _, _ in DialShortcuts.updateAppShortcutParameters() }
                .onChange(of: scenePhase, initial: true) { _, phase in
                    switch phase {
                    case .active:
                        if let request = commands.pending {
                            radio.handleCommand(request.action)
                            commands.clear(request.id)
                        }
                        radio.becameActive()
                    case .background: radio.enteredBackground()
                    case .inactive: break
                    @unknown default: break
                    }
                }
                #if os(macOS)
                .frame(width: 400, height: 720)
                // Mac forms default to a two-column layout; grouped matches the iPhone's inset rows.
                .formStyle(.grouped)
                #endif
    }
}

#if os(macOS)
private struct PlaybackMenu: Commands {
    let radio: RadioPlayer

    var body: some Commands {
        CommandGroup(replacing: .newItem) {}
        CommandMenu("Playback") {
            Button(radio.isActive ? "Pause" : "Play") { radio.toggle() }
                .keyboardShortcut("p", modifiers: .command)
            Divider()
            Button("Next Station") { radio.seek(1) }
                .keyboardShortcut(.rightArrow, modifiers: .command)
            Button("Previous Station") { radio.seek(-1) }
                .keyboardShortcut(.leftArrow, modifiers: .command)
        }
    }
}
#endif
