import XCTest

extension XCUIApplication {
    func openFavorites() {
        buttons["open-stations"].tap()
        segmentedControls.buttons["Favorites"].tap()
    }

    func toggleCurrentFavorite() {
        buttons["open-station-info"].tap()
        buttons["favorite-toggle"].tap()
        buttons["close-station-info"].tap()
    }
}

extension XCUIApplication {
    /// From the player: opens Stations, filters it to a country, and plays one of its stations.
    func chooseCountry(_ id: String, station: String) {
        buttons["open-stations"].tap()
        filterStations(country: id)
        chooseStation(station)
    }

    /// On the Stations screen: filters to one dial location in a country (its main one by default).
    func filterStations(country id: String, location: String? = nil) {
        let main = ["newYork": "newYork", "montevideo": "montevideo-Montevideo", "argentina": "argentina-Buenos Aires",
                    "spain": "spain-online", "unitedKingdom": "unitedKingdom-online"]
        buttons["city-filter"].tap()
        buttons["browse-country-\(id)"].tap()
        buttons["location-\(location ?? main[id]!)"].tap()
    }

    /// Opens Stations from the player and widens the filter from the dial's city to All Locations.
    func openAllStations() {
        buttons["open-stations"].tap()
        let filter = buttons["city-filter"]
        guard filter.waitForExistence(timeout: 5), !filter.label.contains("All Locations") else { return }
        filter.tap()
        buttons["location-all"].tap()
    }

    func chooseStation(_ id: String) {
        let target = buttons["station-\(id)"]
        for _ in 0..<8 { if target.isHittable { break }; swipeUp() }
        XCTAssertTrue(target.isHittable, "Missing station \(id)")
        target.tap()
    }
}
