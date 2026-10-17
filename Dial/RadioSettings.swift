import SwiftUI

struct RadioSettings: View {
    @Bindable var radio: RadioPlayer
    @State private var showsDurations = false
    @MotionReduction private var reduceMotion
    @ScreenDismiss private var dismiss

    var body: some View {
        @Bindable var preferences = radio.preferences
        ScreenStack {
            Form {
                Section("Appearance") {
                    Picker("Appearance", selection: $preferences.appearance) {
                        ForEach(Preferences.Appearance.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("appearance-picker")
                    #if os(iOS)
                    NavigationLink("App icon") { AppIconPicker() }
                        .accessibilityIdentifier("open-icon-picker")
                    #endif
                }
                .listRowBackground(Palette.surface)
                Section {
                    Toggle("Play when opening", isOn: $preferences.autoplayOnOpen)
                        .accessibilityIdentifier("autoplay-on-open")
                    Toggle("Tuning sound", isOn: $radio.tuningSoundEnabled)
                    #if os(iOS)
                    Toggle("Haptic feedback", isOn: $preferences.hapticsEnabled)
                        .accessibilityIdentifier("haptic-feedback")
                    Toggle("Keep awake while charging", isOn: $preferences.keepAwakeWhileCharging)
                        .accessibilityIdentifier("keep-awake")
                    #endif
                    NavigationLink {
                        NarrationSettingsView(preferences: preferences)
                    } label: { LabeledContent("Station announcements", value: preferences.narration.rawValue) }
                    .accessibilityIdentifier("open-narration")
                } header: {
                    Text("Playback")
                } footer: {
                    Text("Automatically plays your last station when you open or return to Dial.")
                }
                .listRowBackground(Palette.surface)
                Section {
                    if let deadline = radio.sleepTimer.deadline {
                        HStack {
                            Label("Stops in", systemImage: "moon.zzz")
                            Spacer()
                            Text(deadline, style: .timer).monospacedDigit()
                        }
                        .accessibilityIdentifier("sleep-countdown")
                        Button("Cancel sleep timer") {
                            radio.sleepTimer.cancel()
                            showsDurations = false
                        }
                        .accessibilityIdentifier("cancel-sleep-timer")
                        DisclosureGroup("Change duration", isExpanded: $showsDurations) {
                            durations
                        }
                        .animation(reduceMotion ? nil : DialMotion.disclosure, value: showsDurations)
                        .transaction { transaction in
                            if reduceMotion { transaction.disablesAnimations = true }
                        }
                    } else {
                        durations
                    }
                } header: {
                    Text("Sleep timer")
                } footer: {
                    Text("Stops playback after the selected time, including while the screen is locked.")
                }
                .listRowBackground(Palette.surface)
                Section("Listening") {
                    #if os(iOS)
                    NavigationLink("Station alarms") { StationAlarmsView(radio: radio) }
                        .accessibilityIdentifier("open-alarms")
                    #endif
                    NavigationLink("Siri & Shortcuts") { RadioShortcutsView() }
                        .accessibilityIdentifier("open-shortcuts")
                }
                .listRowBackground(Palette.surface)
                Section("Library") {
                    NavigationLink("Saved titles") { SavedTitlesView(store: radio.savedItems) }
                        .accessibilityIdentifier("open-saved-titles")
                }
                .listRowBackground(Palette.surface)
                Section {
                    LabeledContent("Version") {
                        Text(version).accessibilityIdentifier("app-version")
                    }
                    Link("Radio Browser", destination: URL(string: "https://www.radio-browser.info/")!)
                        .accessibilityHint("Opens the station directory website")
                        .accessibilityIdentifier("catalog-source")
                } header: {
                    Text("About")
                } footer: {
                    Text("Catalog research uses Radio Browser and broadcaster sources. Artwork credits and verification details appear in each station’s profile.\n\nStation names and logos are trademarks of their respective owners, shown only to identify each station. Dial is not affiliated with or endorsed by any broadcaster.")
                        .accessibilityIdentifier("trademark-notice")
                }
                .listRowBackground(Palette.surface)
            }
            .rowButtons()
            .scrollContentBackground(.hidden)
            .background(Palette.paper)
            .foregroundStyle(Palette.ink)
            .navigationTitle("Settings")
            .inlineNavigationTitle()
            .toolbar { ScreenCloseItem { dismiss() } }
        }
        .tint(Palette.accent)
        .preferredColorScheme(radio.preferences.appearance.scheme)
        .presentationDragIndicator(.visible)
    }

    private var version: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }

    private var durations: some View {
        ForEach([15, 30, 45, 60], id: \.self) { minutes in
            Button("\(minutes) minutes") {
                radio.sleepTimer.start(seconds: Double(minutes * 60))
                showsDurations = false
            }
            .accessibilityIdentifier("sleep-\(minutes)")
        }
    }
}
