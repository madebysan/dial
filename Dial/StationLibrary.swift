import SwiftUI

struct StationLibrary: View {
    @Bindable var radio: RadioPlayer
    @State private var favoritesOnly = false
    @State private var search = ""
    @State private var selectedLocation: String?
    @State private var selectedCountry: RadioRegion?
    @State private var inspectedStation: Station?
    @State private var isLocating = false
    @ScreenDismiss private var dismiss
    @Environment(\.dynamicTypeSize) private var textSize
    @MotionReduction private var reduceMotion

    /// Opens filtered to the dial's current location; All Locations widens it.
    init(radio: RadioPlayer) {
        _radio = Bindable(wrappedValue: radio)
        let station = radio.library.selected
        _selectedCountry = State(initialValue: station.region)
        _selectedLocation = State(initialValue: Self.locationID(station))
    }

    private var showsSearch: Bool {
        !favoritesOnly || !radio.library.favorites.isEmpty || !search.isEmpty
    }
    /// City labels stay visible when one dial location spans several cities, like the New York metro.
    private var showsLocationLabels: Bool {
        guard !favoritesOnly, let selectedLocation else { return true }
        let cities = Set(radio.library.stations.filter { Self.locationID($0) == selectedLocation }.map(\.city))
        return cities.count > 1
    }
    private var locationLabel: String {
        guard let selectedLocation,
            let station = radio.library.stations.first(where: { Self.locationID($0) == selectedLocation })
        else { return "All Locations" }
        return "\(station.hasDial ? station.tuningLocationName : "Other stations") · \(station.region.country)"
    }

    private var filtered: [Station] {
        let source = favoritesOnly ? radio.library.favorites : radio.library.stations
        return source.filter { station in
            (favoritesOnly || ((selectedCountry == nil || station.region == selectedCountry)
                && (selectedLocation == nil || Self.locationID(station) == selectedLocation)))
                && (search.isEmpty
                    || "\(station.name) \(station.detail) \(station.city) \(station.region.country) \(station.frequencyText) \(station.band.displayName)"
                        .localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        ScreenStack {
            Group {
                if showsSearch {
                    libraryContent.searchable(text: $search, prompt: "Name, city, or frequency")
                } else {
                    libraryContent
                }
            }
            .screen(item: $inspectedStation) { station in
                StationInfo(station: station, radio: radio)
                    .preferredColorScheme(radio.preferences.appearance.scheme)
            }
            .sheet(isPresented: $isLocating) {
                LocateCountrySheet(radio: radio) { region in
                    // A lookup finds only the country, so show its main city: the default station's,
                    // else the local dial with the most stations.
                    let locations = radio.library.tuningLocations(in: region)
                    guard let main = locations.first(where: { $0.stations.contains { $0.id == region.defaultStationID } })
                        ?? locations.filter({ !$0.isOnline }).max(by: { $0.stations.count < $1.stations.count })
                        ?? locations.first else { return }
                    selectedCountry = region
                    selectedLocation = main.id
                    favoritesOnly = false
                }
            }
        }
        .tint(Palette.accent)
        .presentationDragIndicator(.visible)
        .preferredColorScheme(radio.preferences.appearance.scheme)
    }

    private var libraryContent: some View {
        VStack(spacing: 0) {
            Picker("Station collection", selection: $favoritesOnly) {
                Text("All stations").tag(false)
                Text("Favorites").tag(true)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)

            if !favoritesOnly {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) {
                        locationMenu.fixedSize(horizontal: true, vertical: false)
                        Spacer(minLength: 0)
                        stationCount.fixedSize()
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        locationMenu
                        stationCount
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }

            if filtered.isEmpty {
                ContentUnavailableView {
                    Label(
                        search.isEmpty ? "A place for your favorites" : "No stations found",
                        systemImage: search.isEmpty ? "star" : "magnifyingglass")
                } description: {
                    Text(
                        search.isEmpty
                            ? "\(Platform.tap) the star beside a station to keep it here."
                            : "Try a station name, city, or frequency.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("empty-stations")
            } else if radio.preferences.layout == .grid {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if favoritesOnly {
                            Text("Saved across locations")
                                .font(.subheadline).foregroundStyle(Palette.secondary)
                        }
                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(.flexible(), spacing: 14, alignment: .top),
                                count: textSize.isAccessibilitySize ? 2 : 3), alignment: .leading, spacing: 24
                        ) {
                            ForEach(filtered) { station in tile(station) }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .accessibilityIdentifier("station-grid")
                .transition(.opacity)
            } else {
                List(filtered) { station in
                    HStack(spacing: 4) {
                        Button {
                            choose(station)
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(station.frequencyText)
                                        .font(.system(size: 25, weight: .light, design: .rounded)).monospacedDigit()
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .accessibilityIdentifier("frequency-\(station.id)")
                                    Text(station.hasDial ? station.band.rawValue : "stream").font(.caption2)
                                }
                                .frame(width: 76, alignment: .leading)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(station.name).font(.system(.headline, design: .rounded))
                                    if showsLocationLabels {
                                        Text("\(station.region.country) · \(station.city)")
                                            .font(.caption).foregroundStyle(Palette.secondary)
                                            .accessibilityIdentifier("location-\(station.id)")
                                    }
                                }
                                Spacer(minLength: 0)
                                if radio.selected.id == station.id {
                                    Image(systemName: radio.isActive ? "waveform" : "checkmark").foregroundStyle(
                                        Palette.accent)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(stationLabel(station))
                        .accessibilityIdentifier("station-\(station.id)")
                        info(station)
                        favorite(station)
                    }
                    .padding(.vertical, 12)
                    .listRowEdgePadding()
                    .listRowBackground(Palette.paper)
                    .listRowSeparatorTint(Palette.line.opacity(0.7))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .accessibilityIdentifier("station-list")
                .transition(.opacity)
            }
        }
        .background(Palette.paper)
        .foregroundStyle(Palette.ink)
        .navigationTitle("Stations")
        .largeNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .screenAccessory) {
                Button {
                    withAnimation(reduceMotion ? nil : DialMotion.collection) {
                        radio.preferences.layout = radio.preferences.layout == .grid ? .list : .grid
                    }
                } label: {
                    StateSymbol(isOn: radio.preferences.layout == .list,
                                off: "list.bullet", on: "square.grid.3x3")
                        .frame(width: 20, height: 20)
                }
                .accessibilityLabel(radio.preferences.layout == .grid ? "Show list" : "Show grid")
                .accessibilityIdentifier("toggle-station-layout")
            }
            ScreenCloseItem { dismiss() }
        }
    }

    private func tile(_ station: Station) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                choose(station)
            } label: {
                VStack(alignment: .leading, spacing: 9) {
                    StationArtwork(station: station)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(alignment: .bottomTrailing) {
                            if radio.selected.id == station.id {
                                Image(systemName: radio.isActive ? "waveform" : "checkmark")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Palette.onAccent)
                                    .padding(8)
                                    .background(Palette.accent, in: Circle())
                                    .padding(7)
                            }
                        }
                    Text(station.name)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .lineLimit(2)
                    Text(station.frequencyLabel)
                        .font(.caption).foregroundStyle(Palette.secondary)
                    if showsLocationLabels {
                        Text(selectedCountry != nil && !favoritesOnly ? station.city : station.region.country)
                            .font(.caption2).foregroundStyle(Palette.secondary)
                            .lineLimit(selectedCountry != nil && !favoritesOnly ? 2 : 1)
                            .accessibilityIdentifier("location-\(station.id)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressFeedback())
            .accessibilityLabel(stationLabel(station))
            .accessibilityIdentifier("station-\(station.id)")
        }
    }

    private func info(_ station: Station) -> some View {
        Button {
            inspectedStation = station
        } label: {
            Image(systemName: "info.circle").font(.system(size: 18))
                .foregroundStyle(Palette.secondary).frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("About \(station.name)")
        .accessibilityIdentifier("info-\(station.id)")
    }

    private func favorite(_ station: Station) -> some View {
        Button {
            radio.library.toggleFavorite(station)
        } label: {
            FavoriteSymbol(isFavorite: radio.library.favoriteIDs.contains(station.id), size: 18)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "\(radio.library.favoriteIDs.contains(station.id) ? "Unsave" : "Save") \(station.name)"
        )
        .accessibilityIdentifier("save-\(station.id)")
    }

    private func stationLabel(_ station: Station) -> String {
        "\(station.name), \(station.frequencyLabel), \(station.detail)"
    }

    /// Matches `RadioLibrary.tuningLocations(in:)`, so the filter groups stations the way the dial does.
    static func locationID(_ station: Station) -> String {
        station.hasDial ? station.dialScope : "\(station.region.rawValue)-online"
    }

    private var stationCount: some View {
        Text("\(filtered.count) \(filtered.count == 1 ? "station" : "stations")")
            .font(.caption)
            .foregroundStyle(Palette.secondary)
            .accessibilityIdentifier("station-count")
    }

    private var locationMenu: some View {
        Menu {
            Button {
                isLocating = true
            } label: {
                Label("Use my location", systemImage: "location.fill")
            }
            .accessibilityIdentifier("detect-country")
            Divider()
            Button {
                selectedLocation = nil
                selectedCountry = nil
            } label: {
                if selectedLocation == nil && selectedCountry == nil {
                    Label("All Locations", systemImage: "checkmark")
                } else {
                    Text("All Locations")
                }
            }
            .accessibilityIdentifier("location-all")
            ForEach(RadioRegion.allCases.filter { !radio.library.stations(in: $0).isEmpty }) { region in
                Menu(region.country) {
                    ForEach(radio.library.tuningLocations(in: region)) { location in
                        Button {
                            selectedLocation = location.id
                            selectedCountry = region
                        } label: {
                            if selectedLocation == location.id {
                                Label(location.name, systemImage: "checkmark")
                            } else {
                                Text(location.name)
                            }
                        }
                        .accessibilityLabel("\(location.name), \(region.country)")
                        .accessibilityIdentifier("location-\(location.id)")
                    }
                }
                .accessibilityIdentifier("browse-country-\(region.rawValue)")
            }
        } label: {
            HStack(spacing: 6) {
                Text(locationLabel).multilineTextAlignment(.leading)
                Image(systemName: "chevron.down").font(.caption2.weight(.semibold))
            }
            .font(.subheadline)
            .frame(minHeight: 44)
        }
        .accessibilityLabel("Location, \(locationLabel)")
        .plainMenuLabel()
        .accessibilityIdentifier("city-filter")
    }

    private func choose(_ station: Station) {
        radio.select(station, autoplay: true)
        dismiss()
    }
}

struct StationArtwork: View {
    let station: Station
    private var profile: StationProfile? { StationProfile.all[station.id] }
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let asset = profile?.artworkAsset {
                    Image(asset).resizable().scaledToFit().padding(12)
                } else {
                    AsyncImage(url: profile?.artworkURL) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFit().padding(12)
                        } else {
                            VStack(spacing: 6) {
                                Text(station.name.prefix(2).uppercased())
                                    .font(.system(size: 32, weight: .light, design: .rounded))
                                Text(station.frequencyText).font(.caption.monospacedDigit())
                            }
                            .foregroundStyle(Palette.artworkInk)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                profile?.artworkBackground == "dark"
                    ? Palette.darkArtwork : Palette.artwork
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .accessibilityHidden(true)
    }
}

/// Finds the listener's country once, then filters Stations to it. The sheet keeps the
/// progress and any Location Services problem visible, which a menu item cannot.
private struct LocateCountrySheet: View {
    let radio: RadioPlayer
    let onFound: (RadioRegion) -> Void
    @State private var locator = CountryLocation()
    @State private var issue: String?
    @Environment(\.dismiss) private var dismiss

    private var message: String? { issue ?? locator.message }

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "location.fill")
                .font(.system(size: 28)).foregroundStyle(Palette.accent)
                .accessibilityHidden(true)
            Text("Use my location").font(.system(.title3, design: .rounded, weight: .semibold))
            Group {
                if locator.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Finding your country…")
                    }
                } else if let message {
                    Text(message).accessibilityIdentifier("location-message")
                }
            }
            .font(.subheadline)
            .foregroundStyle(Palette.secondary)
            .multilineTextAlignment(.center)
            .frame(minHeight: 44)
            Text("Dial uses your location once to find your country and never stores it.")
                .font(.caption).foregroundStyle(Palette.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                Button("Close") { dismiss() }
                    .accessibilityIdentifier("close-locate")
                if !locator.isLoading && message != nil {
                    Button("Try Again") { start() }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(Palette.onAccent)
                        .accessibilityIdentifier("retry-locate")
                }
            }
            .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        #if os(macOS)
        .frame(width: 360)
        #endif
        .foregroundStyle(Palette.ink)
        .background(Palette.paper)
        .tint(Palette.accent)
        .preferredColorScheme(radio.preferences.appearance.scheme)
        .presentationDetents([.height(300)])
        .onAppear { start() }
        .onDisappear { locator.cancel() }
        .onChange(of: locator.countryCode) { _, code in
            guard let code else { return }
            guard let region = RadioRegion(countryCode: code), !radio.library.stations(in: region).isEmpty else {
                issue = "There are no stations for this country yet. Choose one from the list."
                return
            }
            onFound(region)
            dismiss()
        }
    }

    private func start() {
        issue = nil
        locator.request()
    }
}
