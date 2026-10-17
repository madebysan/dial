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
            XCTAssertEqual(library.tuningLocationSummary, "United States · 2 FM stations in Dial")
            XCTAssertEqual(Set(library.dialStations.map(\.id)), ["us-know", "us-kcmp"])
            XCTAssertEqual(library.adjacent(1).id, "us-kcmp")
            XCTAssertFalse(library.dialStations.contains { $0.id == "wfmu" })
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
            XCTAssertEqual(losAngeles.stations.count, 4)
            library.select(losAngeles.stations[0])
            XCTAssertEqual(library.dialStations.count, 4)
            let online = try XCTUnwrap(locations.first { $0.isOnline })
            library.select(online.stations[0])
            XCTAssertEqual(library.tuningLocationName, "Other stations")
            XCTAssertEqual(Set(library.dialStations.map(\.id)), Set(online.stations.map(\.id)))
            XCTAssertTrue(library.tuningLocationSummary.contains("United States"))
        }
    }
}
