import AVKit
import SwiftUI

struct RadioView: View {
    @Bindable var radio: RadioPlayer
    @State private var libraryTab: LibraryTab?
    @State private var previewFrequency: Double?
    @State private var showsVolume = false
    @State private var titleSelection: TitleSelection?
    @MotionReduction private var reduceMotion

    private var displayedStation: Station {
        previewFrequency.flatMap { Station.nearest(to: $0, in: radio.library.dialStations) } ?? radio.selected
    }

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.height < 740
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 28)
                        .padding(.top, 16)

                    Spacer(minLength: compact ? 20 : 32)

                    VStack(spacing: 20) {
                        if radio.selected.hasDial {
                            HStack(alignment: .firstTextBaseline, spacing: 7) {
                                Button {
                                    libraryTab = .info
                                } label: {
                                    FrequencyReadout(
                                        frequency: previewFrequency ?? radio.selected.tuningFrequency, compact: compact,
                                        band: radio.selected.band
                                    )
                                    .id(radio.selected.band)
                                    .animation(reduceMotion ? nil : DialMotion.tune, value: radio.selected.id)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .disabled(previewFrequency != nil)
                                .accessibilityLabel("\(radio.selected.frequencyText) \(radio.selected.band.displayName), \(radio.selected.name)")
                                .accessibilityHint("Opens station information and favorite actions")
                                .accessibilityIdentifier("open-station-frequency")
                                Menu {
                                    ForEach(radio.library.availableBands) { band in
                                        Button(band.displayName) { radio.selectBand(band) }
                                    }
                                } label: {
                                    Text(radio.selected.band.displayName)
                                        + Text(" ⌄")
                                }
                                .plainMenuLabel()
                                .accessibilityIdentifier("select-band")
                                .font(.system(size: 17, weight: .medium, design: .monospaced))
                                .foregroundStyle(Palette.secondary)
                                .padding(.leading, 4)
                            }
                            .accessibilityElement(children: .contain)
                            .padding(.horizontal, 20)
                        } else {
                            Button {
                                libraryTab = .info
                            } label: {
                                StationArtwork(station: radio.selected)
                                    .frame(width: 156, height: 156)
                                    .accessibilityIdentifier("stream-artwork")
                            }
                            .buttonStyle(PressFeedback())
                            .accessibilityLabel("Station details for \(radio.selected.name)")
                            .accessibilityHint("Opens station information and favorite actions")
                            .accessibilityIdentifier("open-station-artwork")
                        }

                        VStack(spacing: 8) {
                            Button {
                                libraryTab = .info
                            } label: {
                                Text(displayedStation.name)
                                    .font(.system(.title, design: .rounded, weight: .medium))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(minHeight: 44)
                                    .accessibilityIdentifier("station-name")
                            }
                            .buttonStyle(PressFeedback())
                            .disabled(previewFrequency != nil)
                            .accessibilityHint("Opens station information and favorite actions")
                            .accessibilityIdentifier("open-station-info")
                            .padding(.horizontal, 24)
                            if !displayedStation.hasDial && displayedStation.city != "National feed"
                                && displayedStation.city != displayedStation.region.country
                                && !displayedStation.city.isEmpty
                            {
                                Text(displayedStation.city)
                                    .font(.subheadline)
                                    .foregroundStyle(Palette.secondary)
                                    .accessibilityIdentifier("station-city")
                            }
                            if let title = radio.liveTitle {
                                Button {
                                    titleSelection = TitleSelection(title: title, station: radio.selected)
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(title).lineLimit(2).multilineTextAlignment(.center)
                                        Image(systemName: "ellipsis.circle").font(.caption)
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(Palette.secondary)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityIdentifier("live-title")
                                .accessibilityLabel(title)
                                .accessibilityHint("Save this title or search music services")
                                .padding(.horizontal, 24)
                            }
                        }
                    }

                    Spacer(minLength: compact ? 10 : 14)

                    if radio.selected.hasDial {
                        TuningDial(
                            stations: radio.library.dialStations, selected: radio.selected,
                            onSelect: { radio.select($0) }, previewFrequency: $previewFrequency,
                            hapticsEnabled: radio.preferences.hapticsEnabled
                        )
                        .id(radio.selected.band)
                    }

                    status
                        .frame(minHeight: 32)
                        .padding(.top, 8)

                    HStack(spacing: 39) {
                        Button {
                            changeStation(-1)
                        } label: {
                            Image(systemName: "backward.end.fill")
                                .font(.system(size: 23, weight: .regular))
                                .frame(width: 52, height: 52)
                        }
                        .accessibilityLabel("Previous station")
                        .accessibilityIdentifier("previous-station")

                        Button {
                            radio.toggle()
                        } label: {
                            StateSymbol(isOn: radio.isActive, off: "play.fill", on: "pause.fill", offOffset: 2)
                                .frame(width: 32, height: 32)
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(MetalPlaybackSurface.ink)
                                .frame(width: 78, height: 78)
                                .background { MetalPlaybackSurface() }
                        }
                        .accessibilityLabel(
                            radio.isActive ? "Pause" : radio.state == .failed ? "Retry playback" : "Play"
                        )
                        .accessibilityIdentifier("play-pause")
                        .accessibilityValue(String(describing: radio.state))

                        Button {
                            changeStation(1)
                        } label: {
                            Image(systemName: "forward.end.fill")
                                .font(.system(size: 23, weight: .regular))
                                .frame(width: 52, height: 52)
                        }
                        .accessibilityLabel("Next station")
                        .accessibilityIdentifier("next-station")
                    }
                    .buttonStyle(PressFeedback())
                    .padding(.top, 12)

                    Spacer(minLength: compact ? 16 : 20)

                    footer
                        .padding(.horizontal, 28)
                        .padding(.bottom, 18)
                }
                .frame(minHeight: geometry.size.height)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(Palette.ink)
        .background(Palette.paper.ignoresSafeArea())
        .preferredColorScheme(radio.preferences.appearance.scheme)
        .onChange(of: radio.externalCommandSequence) { _, _ in
            libraryTab = nil; titleSelection = nil
        }
        #if os(iOS)
        .sheet(item: $titleSelection) { selection in titleActions(selection) }
        .sheet(item: $libraryTab) { tab in screen(tab) }
        #else
        // The player stays alive under a Mac screen but is hidden from clicks and VoiceOver.
        .allowsHitTesting(libraryTab == nil && titleSelection == nil)
        .accessibilityHidden(libraryTab != nil || titleSelection != nil)
        .overlay {
            if let tab = libraryTab {
                screen(tab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Palette.paper.ignoresSafeArea())
                    .environment(\.closeScreen, CloseScreenAction { libraryTab = nil })
                    .transition(reduceMotion ? .identity : .move(edge: .trailing))
            } else if let selection = titleSelection {
                titleActions(selection)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Palette.paper.ignoresSafeArea())
                    .environment(\.closeScreen, CloseScreenAction { titleSelection = nil })
                    .transition(reduceMotion ? .identity : .move(edge: .trailing))
            }
        }
        .animation(reduceMotion ? nil : DialMotion.screen, value: libraryTab)
        .animation(reduceMotion ? nil : DialMotion.screen, value: titleSelection?.id)
        #endif
    }

    private func titleActions(_ selection: TitleSelection) -> some View {
        TitleActionsView(title: selection.title, stationID: selection.station.id,
                         stationName: selection.station.name, store: radio.savedItems)
            .preferredColorScheme(radio.preferences.appearance.scheme)
    }

    @ViewBuilder private func screen(_ tab: LibraryTab) -> some View {
        if tab == .settings {
            RadioSettings(radio: radio)
        } else if tab == .info {
            StationInfo(station: radio.selected, radio: radio)
                .preferredColorScheme(radio.preferences.appearance.scheme)
        } else {
            StationLibrary(radio: radio)
        }
    }

    private var header: some View {
        HStack {
            Spacer()
            iconActions
            Spacer()
        }
        .buttonStyle(PressFeedback())
    }

    @ViewBuilder private var status: some View {
        if previewFrequency != nil {
            Text("Release to tune")
                .font(.caption)
                .foregroundStyle(Palette.secondary)
        } else {
            HStack(spacing: 7) {
                switch radio.state {
                case .connecting:
                    ProgressView().controlSize(.mini).tint(Palette.secondary)
                    Text("Tuning in…")
                case .failed:
                    Image(systemName: "wifi.exclamationmark")
                    Text("Can’t connect. \(Platform.tap) play to retry.")
                case .playing, .paused, .idle:
                    EmptyView()
                }
            }
            .font(.caption)
            .foregroundStyle(radio.state == .failed ? Palette.accent : Palette.secondary)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("playback-status")
        }
    }

    /// One entry point: names the dial's city or metro and opens Stations filtered to it.
    private var footer: some View {
        Button {
            libraryTab = .stations
        } label: {
            Label(radio.library.tuningLocationName, systemImage: "list.bullet")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.vertical, 14)
                .padding(.horizontal, 17)
                .background(Palette.surface, in: Capsule())
        }
        .buttonStyle(PressFeedback())
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Stations, \(radio.library.tuningLocationName), \(radio.library.tuningLocationSummary)")
        .accessibilityHint("Shows the stations here. Choose All Locations to browse everywhere.")
        .accessibilityIdentifier("open-stations")
    }

    private var iconActions: some View {
        HStack(spacing: 0) {
            Button {
                showsVolume = true
            } label: {
                Image(systemName: radio.volume == 0 ? "speaker.slash" : "speaker.wave.2")
                    .font(.system(size: 20))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Volume")
            .accessibilityIdentifier("open-volume")
            .popover(isPresented: $showsVolume, arrowEdge: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Volume").font(.headline)
                    HStack(spacing: 12) {
                        Image(systemName: "speaker.fill")
                        Slider(value: $radio.volume)
                            .tint(Palette.accent)
                            .accessibilityLabel("Playback volume")
                            .accessibilityIdentifier("volume")
                        Image(systemName: "speaker.wave.3.fill")
                    }
                }
                .foregroundStyle(Palette.ink)
                .padding(20)
                .frame(width: 280)
                .presentationBackground(Palette.paper)
                .presentationCompactAdaptation(.popover)
                .preferredColorScheme(radio.preferences.appearance.scheme)
            }
            Button {
                libraryTab = .settings
            } label: {
                Image(systemName: radio.sleepTimer.deadline == nil ? "slider.horizontal.3" : "moon.zzz")
                    .font(.system(size: 20))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Settings and sleep timer")
            .accessibilityIdentifier("open-settings")
            AudioRoutePicker()
                .frame(width: 44, height: 44)
                .accessibilityLabel("Audio output")
            #if os(macOS)
            // A menu bar app has no Dock icon or app menu, so Quit sits with the player's own controls.
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 18))
                    .frame(width: 44, height: 44)
            }
            .keyboardShortcut("q")
            .help("Quit Dial")
            .accessibilityLabel("Quit Dial")
            .accessibilityIdentifier("quit-app")
            #endif
        }
        .buttonStyle(PressFeedback())
    }

    private func changeStation(_ direction: Int) {
        radio.seek(direction)
        Platform.selectionHaptic(enabled: radio.preferences.hapticsEnabled)
    }
}

private enum LibraryTab: String, Identifiable {
    case stations, settings, info
    var id: String { rawValue }
}

struct PressFeedback: ButtonStyle {
    @MotionReduction private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.65 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.95 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#if os(iOS)
struct AudioRoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.tintColor = UIColor(Palette.ink)
        view.activeTintColor = UIColor(Palette.accent)
        view.prioritizesVideoDevices = false
        return view
    }
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
#else
struct AudioRoutePicker: NSViewRepresentable {
    func makeNSView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.isRoutePickerButtonBordered = false
        view.setRoutePickerButtonColor(NSColor(Palette.ink), for: .normal)
        view.setRoutePickerButtonColor(NSColor(Palette.accent), for: .active)
        return view
    }
    func updateNSView(_ nsView: AVRoutePickerView, context: Context) {}
}
#endif

/// A quiet metal face echoes the app icon without changing the playback interaction.
private struct MetalPlaybackSurface: View {
    static let ink = Color(white: 0.12)

    var body: some View {
        Circle()
            .fill(LinearGradient(colors: [Color(white: 0.62), Color(white: 0.18)],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                Circle()
                    .fill(AngularGradient(colors: [
                        Color(white: 0.73), Color(white: 0.96), Color(white: 0.65),
                        Color(white: 0.87), Color(white: 0.70), Color(white: 0.94),
                        Color(white: 0.64), Color(white: 0.73)
                    ], center: .center, angle: .degrees(-45)))
                    .overlay {
                        Circle().strokeBorder(Color.white.opacity(0.45), lineWidth: 0.75)
                    }
                    .padding(3)
            }
            .shadow(color: .black.opacity(0.28), radius: 4, x: 0, y: 3)
            .accessibilityHidden(true)
    }
}

private struct TitleSelection: Identifiable {
    let id = UUID()
    let title: String
    let station: Station
}
