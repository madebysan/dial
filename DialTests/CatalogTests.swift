import XCTest
@testable import Dial

let seedStations = Station.sample.filter {
    Set(["wnyc", "wqxr", "wbgo", "wnyu", "wfuv", "wfmu", "futura", "diamante", "elpuente", "wabc", "clarin"]).contains($0.id)
}

final class CatalogTests: XCTestCase {
    func testDifferentCitiesNeverShareTheSameDial() {
        let first = Station(id: "a", name: "City A", frequency: 91.1, detail: "", city: "City A", region: .argentina,
                            streamURL: URL(string: "https://example.com/a")!, band: .fm)
        let second = Station(id: "b", name: "City B", frequency: 91.1, detail: "", city: "City B", region: .argentina,
                             streamURL: URL(string: "https://example.com/b")!, band: .fm)
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let library = Library(stations: [first, second], defaults: defaults)
        XCTAssertEqual(library.regionalStations.count, 2)
        XCTAssertEqual(library.dialStations.map(\.id), ["a"])
        XCTAssertEqual(library.adjacent(1), first)
        library.select(second)
        XCTAssertEqual(library.dialStations.map(\.id), ["b"])
    }

    func testOnlineStationsHaveNoInventedFrequency() {
        let online = Station(id: "online", name: "Online", frequency: nil, detail: "", city: "Nationwide", region: .spain,
                             streamURL: URL(string: "https://example.com/live")!, band: .online)
        XCTAssertEqual(online.band.displayName, "Other stations")
        XCTAssertEqual(online.band.rawValue, "Live")
        XCTAssertFalse(online.hasDial)
        XCTAssertEqual(online.frequencyLabel, "Live stream")
        XCTAssertNil(Station.nearest(to: 100, in: [online]))
    }

    func testCatalogIntegrity() {
        XCTAssertEqual(Station.sample.count, 469)
        for region in RadioRegion.allCases {
            let expected = region == .newYork ? 238 : region == .canada ? 28 : region == .montevideo ? 24 : region == .unitedKingdom ? 84 : region == .argentina ? 11 : (region == .spain || region == .france) ? 12 : 10
            XCTAssertEqual(Station.sample.filter { $0.region == region }.count, expected, region.name)
        }
        XCTAssertEqual(Set(Station.sample.map(\.id)).count, Station.sample.count)
        for station in Station.sample {
            XCTAssertFalse(station.name.isEmpty)
            XCTAssertTrue(["https", "http"].contains(station.streamURL.scheme))
            XCTAssertEqual(station.frequency == nil, station.band == .online)
            if let frequency = station.frequency { XCTAssertTrue(station.band.range.contains(frequency)) }
            XCTAssertNotNil(StationProfile.all[station.id])
        }
    }
}
