import XCTest
@testable import Dial

/// Stations › All Locations opens with the most-listened stations (docs/all-locations-ranking.md).
final class AllLocationsOrderTests: XCTestCase {
    private var ordered: [Station] {
        let rank = Station.allLocationsRank
        return Station.sample.filter { rank[$0.id] != nil }.sorted { rank[$0.id]! < rank[$1.id]! }
    }

    func testOrderNamesRealStationsOnce() {
        let rank = Station.allLocationsRank
        XCTAssertGreaterThanOrEqual(rank.count, 100)
        let ids = Set(Station.sample.map(\.id))
        XCTAssertTrue(rank.keys.allSatisfy(ids.contains), "Every ranked ID is in the catalogue")
        XCTAssertEqual(Set(rank.values).count, rank.count, "Ranks are unique")
    }

    func testTopThirtyIsAtLeastHalfUnitedStatesAndLeadsWithWNYC() {
        let top = Array(ordered.prefix(30))
        XCTAssertEqual(top.first?.id, "wnyc")
        XCTAssertGreaterThanOrEqual(top.filter { $0.region == .newYork }.count, 15)
        for pick in ["us-kexp", "us-kcrw", "wfmu", "gb-nts1", "fr-fip", "gb-bbc2"] {
            XCTAssertTrue(top.contains { $0.id == pick }, "\(pick) is in the top 30")
        }
    }

    func testCountriesWithoutAudienceFiguresStillAppearEarly() {
        let top = Array(ordered.prefix(120))
        for region in RadioRegion.allCases {
            XCTAssertTrue(top.contains { $0.region == region }, "\(region.country) appears in the first 120")
        }
    }
}
