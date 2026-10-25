import XCTest

final class DeclutterUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        return app
    }

    func testProfileDetailsStayAvailableBehindDisclosure() {
        let app = launch()
        app.buttons["open-station-info"].tap()
        XCTAssertEqual(app.staticTexts["profile-name"].label, "WNYC")
        XCTAssertFalse(app.staticTexts["Country"].exists)
        XCTAssertFalse(app.staticTexts["Profile quality"].exists)
        app.scrollViews["station-info-scroll"].swipeUp()
        capture(app, "Decluttered station profile")
        app.buttons["Sources & stream details"].tap()
        XCTAssertTrue(app.staticTexts["Profile quality"].waitForExistence(timeout: 5))
        app.scrollViews["station-info-scroll"].swipeUp()
        XCTAssertTrue(app.staticTexts["Sources"].exists)
        capture(app, "Expanded sources and stream details")
    }

    func testLocationsAndSingleLineFrequency() {
        let app = launch()
        app.openAllStations()
        let filter = app.buttons["city-filter"]
        let count = app.staticTexts["station-count"]
        XCTAssertEqual(count.label, "469 stations")
        XCTAssertEqual(filter.frame.midY, count.frame.midY, accuracy: 8)
        // Worldwide rows name their city; which station sorts first changes as the catalogue grows.
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "identifier BEGINSWITH 'location-'")).firstMatch.exists)
        capture(app, "Compact worldwide library")
        filter.tap()
        app.buttons["browse-country-newYork"].tap()
        // Seattle sits near the end of a 19-city menu.
        let seattle = app.revealMenuItem("location-newYork-Seattle")
        // iOS 27 drops the custom label inside a nested menu and reads the visible title.
        XCTAssertTrue(["Seattle, United States", "Seattle"].contains(seattle.label), seattle.label)
        capture(app, "Dial-location menu")
        seattle.tap()
        XCTAssertTrue(filter.label.contains("Seattle · United States"))
        XCTAssertEqual(count.label, "10 stations")
        XCTAssertFalse(app.staticTexts["location-us-kexp"].exists)
        capture(app, "Single-city grid without repeated location")
        app.filterStations(country: "newYork", location: "newYork")
        XCTAssertTrue(filter.label.contains("New York metro · United States"))
        XCTAssertEqual(count.label, "22 stations")
        // A metro spans several cities, so each station keeps its city label.
        XCTAssertEqual(app.staticTexts["location-wnyu"].label, "New York")
        app.buttons["toggle-station-layout"].tap()
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("WQXR")
        let frequency = app.staticTexts["frequency-wqxr"]
        XCTAssertTrue(frequency.waitForExistence(timeout: 5))
        XCTAssertEqual(frequency.label, "105.9")
        XCTAssertLessThan(frequency.frame.height, 35)
        XCTAssertTrue(app.staticTexts["location-wqxr"].exists)
        XCTAssertTrue(app.buttons["info-wqxr"].exists)
        XCTAssertTrue(app.buttons["save-wqxr"].exists)
        capture(app, "Single-line 105.9 frequency")
    }

    func testEmptyFavoritesHidesSearchButNoMatchesKeepsIt() {
        let app = launch()
        app.openFavorites()
        XCTAssertFalse(app.searchFields.firstMatch.exists)
        XCTAssertTrue(app.staticTexts["A place for your favorites"].exists)
        capture(app, "Empty favorites without search")
        app.buttons["Done"].tap()
        app.toggleCurrentFavorite()
        app.openFavorites()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.exists)
        search.tap()
        search.typeText("zzznomatch")
        XCTAssertTrue(app.staticTexts["No stations found"].waitForExistence(timeout: 5))
        XCTAssertTrue(search.exists)
        capture(app, "Favorites search with no matches")
    }

    func testLargeTextStacksLibraryContext() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state",
                               "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        let stations = app.buttons["open-stations"]
        for _ in 0..<4 {
            if stations.isHittable { break }
            app.swipeUp()
        }
        stations.tap()
        let filter = app.buttons["city-filter"]
        let count = app.staticTexts["station-count"]
        XCTAssertTrue(filter.exists)
        XCTAssertEqual(count.label, "22 stations")
        XCTAssertGreaterThanOrEqual(count.frame.minY, filter.frame.maxY - 2)
        capture(app, "Library context at accessibility text size")
    }

    func testActiveTimerHidesPresetsUntilRequested() {
        let app = launch()
        app.buttons["open-settings"].tap()
        app.buttons["sleep-15"].tap()
        XCTAssertTrue(app.buttons["cancel-sleep-timer"].exists)
        XCTAssertFalse(app.buttons["sleep-30"].exists)
        capture(app, "Compact active sleep timer")
        app.buttons["Change duration"].tap()
        XCTAssertTrue(app.buttons["sleep-30"].waitForExistence(timeout: 5))
        app.buttons["sleep-30"].tap()
        XCTAssertFalse(app.buttons["sleep-15"].exists)
        app.buttons["cancel-sleep-timer"].tap()
        XCTAssertTrue(app.buttons["sleep-15"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Change duration"].exists)
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = name
        image.lifetime = .keepAlways
        add(image)
    }
}
