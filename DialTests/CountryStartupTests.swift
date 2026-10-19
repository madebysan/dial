import XCTest
@testable import Dial

final class CountryStartupTests: XCTestCase {
    private func withDefaults(_ body: (UserDefaults) throws -> Void) rethrows {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        try body(defaults)
    }

    func testFreshLibraryStartsInTheSuppliedCountry() {
        withDefaults { defaults in
            let library = Library(stations: seedStations, defaults: defaults, initialCountryCode: "UY")
            XCTAssertEqual(library.selected.id, "futura")
            XCTAssertEqual(library.region, .montevideo)
        }
    }

    func testSavedChoiceWinsOverAChangedPhoneRegion() {
        withDefaults { defaults in
            let first = Library(stations: seedStations, defaults: defaults, initialCountryCode: "UY")
            let restored = Library(stations: seedStations, defaults: defaults, initialCountryCode: "US")
            XCTAssertEqual(restored.selected, first.selected)
            XCTAssertEqual(restored.region, .montevideo)
        }
    }

    @MainActor func testUnsupportedCountryStartsInNewYork() {
        withDefaults { defaults in
            let library = Library(stations: seedStations, defaults: defaults, initialCountryCode: "ZZ")
            // The dial always has a location; without a supported region it starts on WNYC.
            XCTAssertEqual(library.selected.id, "wnyc")
            XCTAssertEqual(defaults.string(forKey: "lastStation"), "wnyc")
            let radio = RadioPlayer(library: library, streamOverride: URL(string: "https://127.0.0.1:1/unavailable")!, defaults: defaults)
            radio.volume = 0
            radio.tuningSoundEnabled = false
            defer { radio.pause() }
            radio.selectRegion(.montevideo)
            XCTAssertEqual(defaults.string(forKey: "lastStation"), "futura")
        }
    }

    func testRegionMappingRejectsUnsupportedCountries() {
        XCTAssertEqual(RadioRegion(countryCode: "gb"), .unitedKingdom)
        XCTAssertEqual(RadioRegion(countryCode: "UY"), .montevideo)
        XCTAssertEqual(RadioRegion(countryCode: "CA"), .canada)
        XCTAssertNil(RadioRegion(countryCode: "NZ"))
    }
}
