import XCTest
@testable import Dial

final class LibraryTests: XCTestCase {
    func testBundledProfilesCoverCatalogWithUniqueIDsAndUsableSources() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "station-profiles", withExtension: "json"))
        let profiles = try JSONDecoder().decode([StationProfile].self, from: Data(contentsOf: url))
        XCTAssertEqual(Set(profiles.map(\.stationID)), Set(Station.sample.map(\.id)))
        XCTAssertEqual(profiles.count, Set(profiles.map(\.stationID)).count)
        for profile in profiles {
            XCTAssertFalse(profile.summary.isEmpty)
            XCTAssertFalse(profile.sources.isEmpty)
            if let bitrate = profile.bitrateKbps { XCTAssertGreaterThan(bitrate, 0) }
            XCTAssertTrue(profile.sources.allSatisfy { $0.url.scheme == "https" && $0.url.host != nil })
            if let artwork = profile.artworkURL {
                XCTAssertEqual(artwork.scheme, "https")
                XCTAssertNotNil(artwork.host)
            }
        }
    }

    func testLocationsKeepTheirOwnDialAndRememberLastStation() {
        let name = "DialTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set("wfmu", forKey: "lastStation")
        let library = Library(stations: seedStations, defaults: defaults)
        let futura = library.stations.first { $0.id == "futura" }!
        library.toggleFavorite(library.selected)
        library.select(futura)
        library.toggleFavorite(futura)
        XCTAssertEqual(library.region, .montevideo)
        XCTAssertEqual(library.regionalStations.count, 4)
        XCTAssertEqual(library.adjacent(-1).id, "elpuente")
        XCTAssertEqual(Station.nearest(to: 91.1, in: library.regionalStations)?.id, "futura")
        XCTAssertEqual(library.preferredStation(in: .newYork)?.id, "wfmu")
        XCTAssertEqual(Set(library.favorites.map(\.id)), ["wfmu", "futura"])
        let restored = Library(stations: seedStations, defaults: defaults)
        XCTAssertEqual(restored.region, .montevideo)
        restored.select(restored.preferredStation(in: .newYork)!)
        XCTAssertEqual(restored.selected.id, "wfmu")
        XCTAssertEqual(Station.nearest(to: 91.1, in: restored.regionalStations)?.id, "wfmu")
    }

    @MainActor func testTuningNoiseResourceCanStartAndStop() {
        let noise = TuningNoise()
        noise.start(volume: 0)
        XCTAssertTrue(noise.isPlaying)
        noise.stop(immediately: true)
        XCTAssertFalse(noise.isPlaying)
    }

    func testSelectionAndFavoritesSurviveRelaunch() {
        let name = "DialTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let library = Library(stations: seedStations, defaults: defaults)
        let jazz = library.stations.first { $0.id == "wbgo" }!
        library.select(jazz)
        library.toggleFavorite(jazz)
        let restored = Library(stations: seedStations, defaults: defaults)
        XCTAssertEqual(restored.selected.id, "wbgo")
        XCTAssertEqual(restored.favorites.map(\.id), ["wbgo"])
        restored.toggleFavorite(jazz)
        XCTAssertTrue(Library(stations: seedStations, defaults: defaults).favorites.isEmpty)
    }

    func testDialPicksNearestStationAndSeekWraps() {
        XCTAssertEqual(Station.nearest(to: 93.8, in: seedStations)?.id, "wnyc")
        XCTAssertEqual(Station.nearest(to: 88, in: seedStations)?.id, "wbgo")
        XCTAssertEqual(Station.nearest(to: 108, in: seedStations)?.id, "wqxr")
        let name = "DialTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let library = Library(stations: seedStations, defaults: defaults)
        library.select(library.stations.first { $0.id == "wqxr" }!)
        XCTAssertEqual(library.adjacent(1).id, "wbgo")
        library.select(library.stations.first!)
        XCTAssertEqual(library.adjacent(-1).id, "wqxr")
    }

    func testRemovedStationsDoNotLeaveStaleFavoritesOrSelection() {
        let name = "DialTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(["gone", "wbgo"], forKey: "favorites")
        defaults.set("gone", forKey: "lastStation")
        let library = Library(stations: seedStations, defaults: defaults)
        XCTAssertEqual(library.selected.id, "wnyc")
        XCTAssertEqual(library.favorites.map(\.id), ["wbgo"])
    }
}
