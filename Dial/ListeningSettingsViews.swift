import AppIntents
import AVFoundation
import SwiftUI

struct NarrationSettingsView: View {
    @Bindable var preferences: Preferences
    private var voices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().sorted {
            ($0.language, $0.name) < ($1.language, $1.name)
        }
    }

    var body: some View {
        Form {
            Section {
                Picker("Announce stations", selection: $preferences.narration) {
                    ForEach(Preferences.Narration.allCases) { Text($0.rawValue).tag($0) }
                }
                .accessibilityIdentifier("narration-mode")
            } footer: {
                Text("Speaks the station name when you change stations while playing. Music is lowered during the announcement. VoiceOver takes priority.")
            }
            .listRowBackground(Palette.surface)
            if preferences.narration != .off {
                Section {
                    Picker("Voice", selection: $preferences.narrationVoiceID) {
                        Text("System default").tag("")
                        ForEach(voices, id: \.identifier) { voice in
                            Text("\(voice.name) · \(voice.language)").tag(voice.identifier)
                        }
                    }
                }
                .listRowBackground(Palette.surface)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Palette.paper)
        .screenHeader("Station announcements", close: nil)
    }
}

struct RadioShortcutsView: View {
    var body: some View {
        SettingsList {
            Section {
                #if os(iOS)
                SiriTipView(intent: ResumeRadioIntent())
                ShortcutsLink()
                #else
                Link("Open Shortcuts", destination: URL(string: "shortcuts://")!)
                #endif
            }
            .listRowBackground(Palette.surface)
            Section("Available actions") {
                Label("Play station", systemImage: "radio")
                Label("Play Dial", systemImage: "play.fill")
                Label("Pause Dial", systemImage: "pause.fill")
            }
            .listRowBackground(Palette.surface)
            Section {
                Text("In Shortcuts, choose Play station and select a station. Your favorites are suggested first. These actions open Dial to control playback.")
                    .foregroundStyle(Palette.secondary)
            }
            .listRowBackground(Palette.paper)
        }
        .scrollContentBackground(.hidden)
        .background(Palette.paper)
        .screenHeader("Siri & Shortcuts", close: nil)
    }
}

enum AppIconChoice: String, CaseIterable, Identifiable {
    case knob, monogram, signal, pocket
    var id: String { rawValue }
    var title: String {
        switch self {
        case .knob: "Tuning knob"
        case .monogram: "Monogram"
        case .signal: "Signal"
        case .pocket: "Pocket radio"
        }
    }
    var alternateName: String? {
        switch self {
        case .knob: nil
        case .monogram: "AppIconMonogram"
        case .signal: "AppIconSignal"
        case .pocket: "AppIconPocket"
        }
    }
    var preview: PlatformImage? {
        PlatformImage(named: "IconPreview-\(rawValue)")
    }
}

#if os(iOS)
/// Alternate app icons are an iPhone feature; macOS has no persistent per-app icon switching.
struct AppIconPicker: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selected = UIApplication.shared.alternateIconName
    @State private var isChanging = false
    @State private var errorMessage: String?

    var body: some View {
        List(AppIconChoice.allCases) { choice in
            Button {
                isChanging = true
                Task { @MainActor in
                    defer { isChanging = false }
                    do {
                        try await UIApplication.shared.setAlternateIconName(choice.alternateName)
                        selected = choice.alternateName
                    } catch { errorMessage = "The icon could not be changed. Please try again." }
                }
            } label: {
                HStack(spacing: 16) {
                    if let image = choice.preview {
                        Image(platformImage: image).resizable().frame(width: 54, height: 54)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Text(choice.title).foregroundStyle(Palette.ink)
                    Spacer()
                    if selected == choice.alternateName {
                        Image(systemName: "checkmark").foregroundStyle(Palette.accent)
                    }
                }
                .padding(.vertical, 5)
            }
            .disabled(isChanging || selected == choice.alternateName || !UIApplication.shared.supportsAlternateIcons)
            .accessibilityIdentifier("icon-option-\(choice.id)")
            .accessibilityValue(selected == choice.alternateName ? "Selected" : "")
            .listRowBackground(Palette.surface)
        }
        .scrollContentBackground(.hidden)
        .background(Palette.paper)
        .navigationTitle("App icon")
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { selected = UIApplication.shared.alternateIconName }
        }
        .alert("Couldn’t change icon", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
}
#endif
