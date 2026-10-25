import XCTest

final class WorldCatalogUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testWorldwideLibraryAndLocationFilter() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.openAllStations()
        XCTAssertTrue(app.staticTexts["469 stations"].exists)
        XCTAssertTrue(app.scrollViews["station-grid"].exists)
        capture(app, "Worldwide grid")
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("LOS40")
        XCTAssertTrue(app.buttons["station-es-los40"].waitForExistence(timeout: 5))
        app.buttons["station-es-los40"].tap()
        XCTAssertTrue(app.buttons["open-stations"].label.contains("Spain"))
        app.openAllStations()
        app.buttons["toggle-station-layout"].tap()
        XCTAssertTrue(app.collectionViews["station-list"].exists)
        search.tap()
        search.typeText("Alfa")
        XCTAssertTrue(app.buttons["station-mx-alfa"].waitForExistence(timeout: 5))
        capture(app, "Worldwide list search")
        app.buttons["station-mx-alfa"].tap()
        app.terminate()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["open-stations"].label.contains("Mexico"))
        app.openAllStations()
        app.buttons["city-filter"].tap()
        app.buttons["browse-country-newYork"].tap(); app.revealMenuItem("location-newYork").tap()
        search.tap()
        search.typeText("Alfa")
        XCTAssertTrue(app.staticTexts["No stations found"].waitForExistence(timeout: 5))
        app.buttons["city-filter"].tap()
        app.buttons["location-all"].tap()
        XCTAssertTrue(app.buttons["station-mx-alfa"].waitForExistence(timeout: 5))
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = name
        image.lifetime = .keepAlways
        add(image)
    }

    func testCountryCollectionsAndSearch() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        let countries = [("newYork", "United States", 238), ("canada", "Canada", 28), ("montevideo", "Uruguay", 24),
                         ("argentina", "Argentina", 11), ("spain", "Spain", 12),
                         ("brazil", "Brazil", 10), ("mexico", "Mexico", 10),
                         ("colombia", "Colombia", 10), ("chile", "Chile", 10),
                         ("unitedKingdom", "United Kingdom", 84), ("france", "France", 12),
                         ("italy", "Italy", 10), ("japan", "Japan", 10)]
        // Each country's Other stations, or its city dial where every station has a local frequency.
        let probes: [String: (location: String, label: String, count: Int)] = [
            "newYork": ("newYork-online", "Other stations", 9), "canada": ("canada-Toronto", "Toronto", 10), "montevideo": ("montevideo-online", "Other stations", 7),
            "argentina": ("argentina-online", "Other stations", 2), "spain": ("spain-online", "Other stations", 2),
            "brazil": ("brazil-online", "Other stations", 6), "mexico": ("mexico-online", "Other stations", 1),
            "colombia": ("colombia-online", "Other stations", 7), "chile": ("chile-Santiago", "Santiago", 10),
            "unitedKingdom": ("unitedKingdom-online", "Other stations", 81), "france": ("france-Paris", "Paris", 12),
            "italy": ("italy-Milan", "Milan", 10), "japan": ("japan-online", "Other stations", 10)]
        for (id, name, _) in countries {
            app.openAllStations()
            if id == "mexico" {
                app.filterStations(country: id, location: "mexico-Mexico City")
                XCTAssertEqual(app.staticTexts["station-count"].label, "9 stations")
            }
            let probe = probes[id]!
            app.filterStations(country: id, location: probe.location)
            XCTAssertTrue(app.buttons["city-filter"].label.contains(probe.label))
            XCTAssertEqual(app.staticTexts["station-count"].label,
                           "\(probe.count) \(probe.count == 1 ? "station" : "stations")", "\(probe.label) in \(name)")
            capture(app, "\(probe.label) - \(name)")
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'station-'")).firstMatch.tap()
            XCTAssertTrue(app.buttons["open-stations"].label.contains(name))
            XCTAssertTrue(app.buttons["open-stations"].label.contains(probe.label))
            app.openAllStations()
            XCTAssertTrue(app.scrollViews["station-grid"].exists)
            let image = XCTAttachment(screenshot: app.screenshot())
            image.name = "Catalogue - \(name)"
            image.lifetime = .keepAlways
            add(image)
            if id == "mexico" {
                let search = app.searchFields.firstMatch
                search.tap()
                search.typeText("Alfa")
                XCTAssertTrue(app.buttons["station-mx-alfa"].waitForExistence(timeout: 5))
                XCTAssertFalse(app.buttons["station-mx-exa"].exists)
                app.buttons["station-mx-alfa"].tap()
                XCTAssertEqual(app.buttons["open-station-info"].label, "Alfa 91.3")
            } else {
                app.buttons["Done"].tap()
            }
        }
    }
}
