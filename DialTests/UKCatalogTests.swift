import XCTest
@testable import Dial

final class UKCatalogTests: XCTestCase {
    func testOnlineStationsUseNaturalNameOrder() {
        let stations = ["BBC Radio 6 Music", "BBC Radio 2", "BBC Radio 1"].map { name in
            Station(id: name, name: name, frequency: nil, detail: "", city: "National feed",
                    region: .unitedKingdom, streamURL: URL(string: "https://example.com/radio")!, band: .online)
        }
        let key = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: key)!
        defer { defaults.removePersistentDomain(forName: key) }
        let library = Library(stations: stations, defaults: defaults)
        XCTAssertEqual(library.stations.map(\.name), ["BBC Radio 1", "BBC Radio 2", "BBC Radio 6 Music"])
    }
    func testBBCSelectionFavoritesAndProfileCoverage() {
        let uk = Station.sample.filter { $0.region == .unitedKingdom }
        XCTAssertEqual(uk.count, 84)
        XCTAssertEqual(uk.filter { $0.name.hasPrefix("BBC ") }.count, 66)
        let ids: Set<String> = ["gb-bbc-world", "gb-bbc2", "gb-bbc4", "gb-bbc6"]
        let key = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: key)!
        defer { defaults.removePersistentDomain(forName: key) }
        defaults.set(Array(ids), forKey: "favorites")
        defaults.set("gb-bbc6", forKey: "lastStation")
        defaults.set(["unitedKingdom": "gb-bbc2"], forKey: "lastStationsByRegion")
        let library = Library(defaults: defaults)
        XCTAssertEqual(library.selected.id, "gb-bbc6")
        XCTAssertEqual(library.favoriteIDs, ids)
        XCTAssertEqual(library.preferredStation(in: .unitedKingdom)?.id, "gb-bbc2")
        for station in uk { XCTAssertNotNil(StationProfile.all[station.id]) }
        XCTAssertEqual(StationProfile.all["gb-bbc-radio-cymru"]?.languages, ["Welsh"])
        XCTAssertEqual(StationProfile.all["gb-bbc-radio-nan-gaidheal"]?.languages, ["Scottish Gaelic"])
        XCTAssertEqual(StationProfile.all["gb-bbc-radio-guernsey"]?.locationLabel, "Guernsey · Channel Islands")
    }

}
