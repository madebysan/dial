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
                    "spain": "spain-Madrid", "unitedKingdom": "unitedKingdom-online"]
        buttons["city-filter"].tap()
        buttons["browse-country-\(id)"].tap()
        // Country menus with many cities scroll; Other stations sits at the end.
        revealMenuItem("location-\(location ?? main[id]!)").tap()
    }

    /// Waits for an open menu, then scrolls it until the item can be tapped. Swiping before the menu
    /// has appeared would dismiss it.
    func revealMenuItem(_ identifier: String) -> XCUIElement {
        let target = menuItem(identifier)
        _ = target.waitForExistence(timeout: 3)
        for _ in 0..<6 where !target.isHittable { swipeUp() }
        return target
    }

    /// iOS 27 drops the accessibility identifier and label from items inside a nested Menu, so a
    /// country's city items are matched by their visible title there. iOS 26 keeps the identifier.
    func menuItem(_ identifier: String) -> XCUIElement {
        guard let title = Self.locationTitle(identifier) else { return buttons[identifier] }
        let match = NSPredicate(format: "identifier == %@ OR (identifier == '' AND label == %@)", identifier, title)
        return buttons.matching(match).firstMatch
    }

    /// The menu title for a `location-<dial scope>` identifier, mirroring `Library.tuningLocations`.
    private static func locationTitle(_ identifier: String) -> String? {
        guard identifier.hasPrefix("location-") else { return nil }
        let scope = String(identifier.dropFirst("location-".count))
        switch scope {
        case "newYork": return "New York metro"
        case "losAngeles": return "Los Angeles"
        case _ where scope.hasSuffix("-online"): return "Other stations"
        default:
            let parts = scope.split(separator: "-", maxSplits: 1)
            return parts.count == 2 ? String(parts[1]) : nil
        }
    }

    /// Opens Stations from the player and widens the filter from the dial's city to All Locations.
    func openAllStations() {
        buttons["open-stations"].tap()
        let filter = buttons["city-filter"]
        guard filter.waitForExistence(timeout: 5), !filter.label.contains("All Locations") else { return }
        filter.tap()
        buttons["location-all"].tap()
    }

    /// Scrolls until the whole tile is on screen: a tile cut off at the bottom edge can be "hittable"
    /// while the tap lands below it.
    func chooseStation(_ id: String) {
        let target = buttons["station-\(id)"]
        let bottom = windows.firstMatch.frame.maxY - 40
        // A slow swipe moves about a row; a default swipeUp() can fling a last-row tile past the top.
        for _ in 0..<12 { if target.isHittable && target.frame.maxY <= bottom { break }; swipeUp(velocity: .slow) }
        XCTAssertTrue(target.isHittable, "Missing station \(id)")
        target.tap()
    }
}
