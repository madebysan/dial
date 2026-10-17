import SwiftUI

struct TitleActionsView: View {
    let title: String
    let stationID: String
    let stationName: String
    let store: SavedItems
    @State private var errorMessage: String?
    @ScreenDismiss private var dismiss
    @Environment(\.inScreenStack) private var pushed

    private var station: Station? { Station.sample.first { $0.id == stationID } }

    var body: some View {
        ScreenStack {
            Form {
                Section {
                    Text(title).font(.headline).accessibilityIdentifier("title-action-name")
                    Text(stationName).foregroundStyle(Palette.secondary)
                    if let station {
                        Button(store.containsTitle(title) ? "Saved" : "Save title") {
                            do { try store.saveTitle(title, station: station) }
                            catch { errorMessage = error.localizedDescription }
                        }
                        .disabled(store.containsTitle(title))
                        .accessibilityIdentifier("save-current-title")
                    }
                }
                .listRowBackground(Palette.surface)
                Section("Find in music services") {
                    ForEach(MusicSearch.allCases) { service in
                        if let url = service.url(for: title) {
                            Link(service.rawValue, destination: url)
                        }
                    }
                }
                .listRowBackground(Palette.surface)
                Section {
                    ShareLink(item: "\(title)\nHeard on \(stationName)") {
                        Label("Share title", systemImage: "square.and.arrow.up")
                    }
                } footer: {
                    Text("Uses the title provided by the station, which can also be a program name. Music-service links open a search.")
                }
                .listRowBackground(Palette.surface)
            }
            .rowButtons()
            .scrollContentBackground(.hidden)
            .background(Palette.paper)
            .foregroundStyle(Palette.ink)
            .navigationTitle("Now playing")
            .inlineNavigationTitle()
            .toolbar {
                // On Mac, a title opened from Saved titles uses the system back button instead.
                if Platform.isPhone || !pushed { ScreenCloseItem { dismiss() } }
            }
        }
        .tint(Palette.accent)
        .alert("Couldn’t save title", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
}

struct SavedTitlesView: View {
    let store: SavedItems
    @State private var selected: SavedTitle?
    @State private var errorMessage: String?

    var body: some View {
        SettingsList {
            if let issue = store.storageIssue { Text(issue).foregroundStyle(Palette.secondary) }
            if store.titles.isEmpty {
                ContentUnavailableView("No saved titles", systemImage: "music.note",
                                       description: Text("\(Platform.tap) a song or program title in the player to save it."))
                    .listRowBackground(Palette.paper)
            }
            ForEach(store.titles) { item in
                Button { selected = item } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.title).foregroundStyle(Palette.ink)
                        Text(item.stationName).font(.caption).foregroundStyle(Palette.secondary)
                    }
                }
                .listRowBackground(Palette.surface)
                .contextMenu {
                    // Mac has no swipe to delete.
                    Button("Delete", role: .destructive) {
                        do { try store.removeTitles([item.id]) } catch { errorMessage = error.localizedDescription }
                    }
                }
                .accessibilityIdentifier("saved-title-\(item.id)")
            }
            .onDelete { offsets in
                do { try store.removeTitles(Set(offsets.map { store.titles[$0].id })) }
                catch { errorMessage = error.localizedDescription }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Palette.paper)
        .navigationTitle("Saved titles")
        .screen(item: $selected) { item in
            TitleActionsView(title: item.title, stationID: item.stationID, stationName: item.stationName, store: store)
        }
        .alert("Couldn’t update saved titles", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
}
