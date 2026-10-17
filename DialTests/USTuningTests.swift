import XCTest
@testable import Dial

final class USTuningTests: XCTestCase {
    func testUSCitiesKeepSeparateDialsAndBandMemory() {
        let ny = station("ny", city: "New York", frequency: 91.1)
        let la = station("la", city: "Los Angeles", frequency: 91.1)
        let laNext = station("la-next", city: "Los Angeles", frequency: 93.1)
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let library = Library(stations: [ny, la, laNext], defaults: defaults)
        XCTAssertEqual(library.dialStations.map(\.id), ["ny"])
        library.select(la)
        XCTAssertEqual(Set(library.dialStations.map(\.id)), ["la", "la-next"])
        XCTAssertEqual(library.adjacent(1).id, "la-next")
        library.select(laNext)
        library.select(ny)
        XCTAssertEqual(library.preferredStation(band: .fm)?.id, "ny")
        library.select(la)
        library.select(laNext)
        let restored = Library(stations: [ny, la, laNext], defaults: defaults)
        XCTAssertEqual(restored.selected.id, "la-next")
        XCTAssertEqual(restored.preferredStation(band: .fm)?.id, "la-next")
    }

    func testMetroGroupingPreservesOriginalBandKeys() {
        var ny = station("ny", city: "New York", frequency: 91.1)
        var nj = station("nj", city: "Newark", frequency: 88.3)
        ny.tuningArea = "newYork"
        nj.tuningArea = "newYork"
        let la = station("la", city: "Los Angeles", frequency: 91.1)
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(["newYork-FM": "nj"], forKey: "lastStationsByBand")
        let library = Library(stations: [ny, nj, la], defaults: defaults)
        XCTAssertEqual(Set(library.dialStations.map(\.id)), ["ny", "nj"])
        XCTAssertEqual(library.preferredStation(band: .fm)?.id, "nj")
        XCTAssertEqual(RadioRegion.newYork.name, "United States")
    }

    private func station(_ id: String, city: String, frequency: Double) -> Station {
        Station(id: id, name: id, frequency: frequency, detail: "", city: city, region: .newYork,
                streamURL: URL(string: "https://example.com/\(id)")!, band: .fm)
    }
}
