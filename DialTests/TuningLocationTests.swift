import XCTest
@testable import Dial

final class TuningLocationTests: XCTestCase {
    private func withLibrary(_ body: (Library) throws -> Void) rethrows {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        try body(Library(defaults: defaults))
    }

    func testMinneapolisScopeExcludesSameFrequencyInNewYork() throws {
        try withLibrary { library in
            let mpr = try XCTUnwrap(library.stations.first { $0.id == "us-know" })
            library.select(mpr)
            XCTAssertEqual(library.tuningLocationName, "Minneapolis–Saint Paul")
            // Ten Twin Cities FM stations since the Oct 18, 2026 North America batch (KMOJ added for its Reddit following); WCCO is on AM.
            XCTAssertEqual(library.tuningLocationSummary, "United States · 10 FM stations in Dial")
            XCTAssertEqual(Set(library.dialStations.map(\.id)),
                           ["us-kcmp", "us-kmoj", "us-kfai", "us-know", "us-kstp", "us-ksjn", "us-kfxn", "us-kdwb", "us-keey", "us-kqql"])
            XCTAssertEqual(library.adjacent(1).id, "us-kstp")
            XCTAssertEqual(library.adjacent(-1).id, "us-kfai")
            XCTAssertFalse(library.dialStations.contains { $0.id == "wfmu" })
        }
    }

    /// Batch A (Oct 18, 2026): stations that were national feeds now sit on their city's FM dial.
    func testParisMadridMilanAndSantiagoDials() throws {
        try withLibrary { library in
            let expected: [(RadioRegion, String, Int, String, Double)] = [
                (.france, "Paris", 12, "fr-fip", 105.1), (.spain, "Madrid", 10, "es-ser", 105.4),
                (.italy, "Milan", 10, "it-deejay", 99.7), (.chile, "Santiago", 10, "cl-beethoven", 97.7)]
            for (region, city, count, sample, frequency) in expected {
                let dial = try XCTUnwrap(library.tuningLocations(in: region).first { $0.name == city }, city)
                XCTAssertEqual(dial.stations.count, count, city)
                XCTAssertTrue(dial.stations.allSatisfy { $0.band == .fm && $0.hasDial }, city)
                XCTAssertEqual(Set(dial.stations.map(\.frequency)).count, count, "\(city) frequencies must be unique")
                XCTAssertEqual(dial.stations.first { $0.id == sample }?.frequency, frequency, sample)
            }
            // Catalunya Ràdio and RAC1 broadcast in Catalonia, so they stay under Spain's Other stations.
            let spainOnline = try XCTUnwrap(library.tuningLocations(in: .spain).first { $0.isOnline })
            XCTAssertEqual(Set(spainOnline.stations.map(\.id)), ["es-catalunya", "es-rac1"])
            XCTAssertNil(library.tuningLocations(in: .france).first { $0.isOnline })
        }
    }

    func testLocationGroupsCoverEveryCountryStationExactlyOnce() {
        withLibrary { library in
            for region in RadioRegion.allCases {
                let groups = library.tuningLocations(in: region)
                XCTAssertEqual(Set(groups.map(\.name)).count, groups.count, "Duplicate location in \(region.country)")
                let ids = groups.flatMap { $0.stations.map(\.id) }
                XCTAssertEqual(ids.count, Set(ids).count)
                XCTAssertEqual(Set(ids), Set(library.stations(in: region).map(\.id)))
                for group in groups {
                    XCTAssertFalse(group.stations.isEmpty)
                    XCTAssertNotNil(library.preferredStation(in: group))
                    if !group.isOnline { XCTAssertEqual(Set(group.stations.map(\.dialScope)).count, 1) }
                }
            }
        }
    }

    func testMetroGroupsNeighboringCitiesAndOnlineSpansCountry() throws {
        try withLibrary { library in
            let locations = library.tuningLocations(in: .newYork)
            let metro = try XCTUnwrap(locations.first { $0.id == "newYork" })
            XCTAssertEqual(metro.name, "New York metro")
            XCTAssertTrue(metro.stations.contains { $0.city == "Jersey City" })
            XCTAssertTrue(metro.stations.contains { $0.city == "New York" })
            let losAngeles = try XCTUnwrap(locations.first { $0.id == "losAngeles" })
            XCTAssertEqual(losAngeles.stations.count, 10)
            library.select(losAngeles.stations[0])
            // Eight FM stations share the Los Angeles FM dial; KFI and KNX are on AM.
            XCTAssertEqual(library.dialStations.count, 8)
            let online = try XCTUnwrap(locations.first { $0.isOnline })
            library.select(online.stations[0])
            XCTAssertEqual(library.tuningLocationName, "Other stations")
            XCTAssertEqual(Set(library.dialStations.map(\.id)), Set(online.stations.map(\.id)))
            XCTAssertTrue(library.tuningLocationSummary.contains("United States"))
        }
    }
}
