import XCTest

final class WorldCatalogUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testWorldwideLibraryAndLocationFilter() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.openAllStations()
        XCTAssertTrue(app.staticTexts["249 stations"].exists)
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
        app.buttons["browse-country-newYork"].tap(); app.buttons["location-newYork"].tap()
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
        let countries = [("newYork", "United States", 56), ("montevideo", "Uruguay", 14),
                         ("argentina", "Argentina", 11), ("spain", "Spain", 12),
                         ("brazil", "Brazil", 10), ("mexico", "Mexico", 10),
                         ("colombia", "Colombia", 10), ("chile", "Chile", 10),
                         ("unitedKingdom", "United Kingdom", 84), ("france", "France", 12),
                         ("italy", "Italy", 10), ("japan", "Japan", 10)]
        let otherCounts = ["newYork": 9, "montevideo": 7, "argentina": 2, "spain": 12,
                           "brazil": 6, "mexico": 1, "colombia": 7, "chile": 10,
                           "unitedKingdom": 81, "france": 12, "italy": 10, "japan": 10]
        for (id, name, _) in countries {
            app.openAllStations()
            if id == "mexico" {
                app.filterStations(country: id, location: "mexico-Mexico City")
                XCTAssertEqual(app.staticTexts["station-count"].label, "9 stations")
            }
            app.filterStations(country: id, location: "\(id)-online")
            XCTAssertTrue(app.buttons["city-filter"].label.contains("Other stations"))
            let otherCount = otherCounts[id]!
            XCTAssertEqual(app.staticTexts["station-count"].label,
                           "\(otherCount) \(otherCount == 1 ? "station" : "stations")", "Other stations in \(name)")
            capture(app, "Other stations - \(name)")
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'station-'")).firstMatch.tap()
            XCTAssertTrue(app.buttons["open-stations"].label.contains(name))
            XCTAssertTrue(app.buttons["open-stations"].label.contains("Other stations"))
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
