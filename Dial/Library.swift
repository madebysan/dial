import Foundation
import Observation

@Observable
final class Library {
    let stations: [Station]
    private(set) var selected: Station
    private(set) var favoriteIDs: Set<String>
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let cloud: FavoritesCloudStore?

    init(stations: [Station] = Station.sample, defaults: UserDefaults = .standard, initialCountryCode: String? = "US",
         cloud: FavoritesCloudStore? = nil) {
        precondition(!stations.isEmpty)
        self.stations = stations.sorted {
            let first = $0.frequency ?? .infinity
            let second = $1.frequency ?? .infinity
            if first != second { return first < second }
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
        self.defaults = defaults
        self.cloud = cloud
        let saved = defaults.string(forKey: "lastStation")
        let restored = stations.first { $0.id == saved }
        let region = initialCountryCode.flatMap(RadioRegion.init(countryCode:))
        let local = stations.filter { $0.region == region }
        let initial = local.first { $0.id == region?.defaultStationID } ?? local.first
        selected = restored ?? initial ?? stations.first { $0.id == "wnyc" } ?? stations[0]
        favoriteIDs = Set(defaults.stringArray(forKey: "favorites") ?? [])
            .intersection(stations.map(\.id))
        // The dial always has a location: an unsupported region starts in New York.
        defaults.set(selected.id, forKey: "lastStation")
        cloud?.onExternalChange = { [weak self] change in self?.applyCloudFavorites(merging: change == .joined) }
        applyCloudFavorites(merging: false)
    }

    /// Merging keeps both sides' favorites (until this device has seen iCloud's list once, or after an
    /// account change); otherwise iCloud's list wins, so a removal on one device removes it everywhere.
    private func applyCloudFavorites(merging requested: Bool) {
        guard let cloud else { return }
        let merging = requested || !defaults.bool(forKey: "favoritesJoinedCloud")
        guard let remote = cloud.favoriteIDs() else {
            // Nothing downloaded yet. Offer this device's favorites; iCloud reports its own list as a join.
            if !favoriteIDs.isEmpty { pushFavorites() }
            return
        }
        let known = Set(remote).intersection(stations.map(\.id))
        let merged = merging ? favoriteIDs.union(known) : known
        if merged != favoriteIDs {
            favoriteIDs = merged
            defaults.set(favoriteIDs.sorted(), forKey: "favorites")
        }
        if merging {
            defaults.set(true, forKey: "favoritesJoinedCloud")
            pushFavorites()
        }
    }

    private func pushFavorites() {
        guard let cloud else { return }
        // Keep favorites this catalogue doesn't know, such as stations added in a newer version on another device.
        let unknown = Set(cloud.favoriteIDs() ?? []).subtracting(stations.map(\.id))
        let ids = favoriteIDs.union(unknown).sorted()
        if cloud.favoriteIDs() != ids { cloud.setFavoriteIDs(ids) }
    }

    var favorites: [Station] { stations.filter { favoriteIDs.contains($0.id) } }
    var region: RadioRegion { selected.region }
    var regionalStations: [Station] { stations(in: region) }
    var dialStations: [Station] { regionalStations.filter { $0.band == selected.band && (!selected.hasDial || $0.dialScope == selected.dialScope) } }

    var tuningLocationName: String { selected.hasDial ? selected.tuningLocationName : "Other stations" }
    var tuningLocationSummary: String {
        let count = dialStations.count
        if !selected.hasDial { return "\(region.country) · \(count) \(count == 1 ? "station" : "stations") in Dial" }
        return "\(region.country) · \(count) \(selected.band.displayName) \(count == 1 ? "station" : "stations") in Dial"
    }

    func tuningLocations(in region: RadioRegion) -> [TuningLocation] {
        let groups = Dictionary(grouping: stations(in: region), by: { $0.hasDial ? $0.dialScope : "\(region.rawValue)-online" })
        return groups.map { key, stations in
            TuningLocation(id: key, name: stations[0].hasDial ? stations[0].tuningLocationName : "Other stations",
                           stations: stations, isOnline: !stations[0].hasDial)
        }.sorted { lhs, rhs in
            if lhs.isOnline != rhs.isOnline { return !lhs.isOnline }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }

    func preferredStation(in location: TuningLocation) -> Station? {
        if location.stations.contains(selected) { return selected }
        if let remembered = preferredStation(in: location.stations[0].region), location.stations.contains(remembered) { return remembered }
        return location.stations.first { $0.band == selected.band } ?? location.stations.first
    }

    var availableBands: [RadioBand] {
        RadioBand.allCases.filter { band in
            regionalStations.contains { $0.band == band && (band == .online || $0.dialScope == selected.dialScope) }
        }
    }

    func preferredStation(band: RadioBand) -> Station? {
        let candidates = regionalStations.filter { $0.band == band && (band == .online || $0.dialScope == selected.dialScope) }
        let saved = defaults.dictionary(forKey: "lastStationsByBand") as? [String: String] ?? [:]
        return candidates.first { $0.id == saved["\(selected.dialScope)-\(band.rawValue)"] }
            ?? candidates.first { $0.id == saved["\(region.rawValue)-\(selected.city)-\(band.rawValue)"] }
            ?? candidates.first { $0.id == saved["\(region.rawValue)-\(band.rawValue)"] }
            ?? candidates.first
    }

    func stations(in region: RadioRegion) -> [Station] {
        stations.filter { $0.region == region }
    }

    func preferredStation(in region: RadioRegion) -> Station? {
        let candidates = stations(in: region)
        let saved = defaults.dictionary(forKey: "lastStationsByRegion") as? [String: String] ?? [:]
        return candidates.first { $0.id == saved[region.rawValue] }
            ?? candidates.first { $0.id == region.defaultStationID } ?? candidates.first
    }

    func select(_ station: Station) {
        guard stations.contains(station) else { return }
        var saved = defaults.dictionary(forKey: "lastStationsByRegion") as? [String: String] ?? [:]
        // Preserve the current choice when migrating the original single-city state.
        saved[selected.region.rawValue] = selected.id
        var bands = defaults.dictionary(forKey: "lastStationsByBand") as? [String: String] ?? [:]
        bands["\(selected.dialScope)-\(selected.band.rawValue)"] = selected.id
        bands["\(station.dialScope)-\(station.band.rawValue)"] = station.id
        defaults.set(bands, forKey: "lastStationsByBand")
        selected = station
        defaults.set(station.id, forKey: "lastStation")
        saved[station.region.rawValue] = station.id
        defaults.set(saved, forKey: "lastStationsByRegion")
    }

    func toggleFavorite(_ station: Station) {
        if !favoriteIDs.insert(station.id).inserted { favoriteIDs.remove(station.id) }
        defaults.set(favoriteIDs.sorted(), forKey: "favorites")
        pushFavorites()
    }

    func adjacent(_ direction: Int) -> Station {
        let candidates = dialStations
        let current = candidates.firstIndex(of: selected) ?? 0
        return candidates[(current + direction + candidates.count) % candidates.count]
    }
}
