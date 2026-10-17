import XCTest

final class USExpansionUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testDarkModeAcrossNewPlayerAndSheetsPersists() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.buttons["play-pause"].tap()
        app.buttons["open-settings"].tap()
        app.buttons["Dark"].tap()
        XCTAssertTrue(app.buttons["Dark"].isSelected)
        capture(app, "Dark appearance setting")
        app.buttons["Done"].tap()
        capture(app, "Dark FM player")
        app.buttons["open-station-info"].tap()
        XCTAssertTrue(app.buttons["favorite-toggle"].exists)
        capture(app, "Dark station details and favorite action")
        app.buttons["close-station-info"].tap()
        app.openAllStations()
        capture(app, "Dark expanded station grid")
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("KEXP")
        app.buttons["station-us-kexp"].tap()
        app.buttons["play-pause"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "KEXP")
        capture(app, "Dark Seattle player")
        app.buttons["open-volume"].tap()
        capture(app, "Dark volume")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.08, dy: 0.65)).tap()
        app.buttons["open-stations"].tap()
        capture(app, "Dark stations at the dial location")
        app.buttons["Done"].tap()
        app.terminate()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        app.buttons["open-settings"].tap()
        XCTAssertTrue(app.buttons["Dark"].isSelected)
        app.buttons["Light"].tap()
        XCTAssertTrue(app.buttons["Light"].isSelected)
        capture(app, "Light appearance setting")
        app.buttons["Done"].tap()
        capture(app, "Neutral light FM player")
        app.openAllStations()
        let libraryBar = app.navigationBars["Stations"]
        let sheetPresented = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in libraryBar.exists && libraryBar.frame.minY < 150 },
            object: nil
        )
        XCTAssertEqual(XCTWaiter.wait(for: [sheetPresented], timeout: 5), .completed)
        capture(app, "Neutral light station grid")
        app.buttons["Done"].tap()
        app.buttons["open-station-info"].tap()
        capture(app, "Neutral light station details")
        app.buttons["close-station-info"].tap()
        app.buttons["open-settings"].tap()
        app.buttons["System"].tap()
        XCTAssertTrue(app.buttons["System"].isSelected)
    }

    func testUSCitySearchAndDialStayLocal() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        XCTAssertTrue(app.buttons["open-stations"].label.contains("United States"))
        app.openAllStations()
        app.filterStations(country: "newYork", location: "newYork")
        XCTAssertEqual(app.staticTexts["station-count"].label, "22 stations")
        XCTAssertTrue(app.buttons["city-filter"].label.contains("New York metro"))
        app.buttons["city-filter"].tap()
        app.buttons["location-all"].tap()
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("Seattle")
        XCTAssertTrue(app.buttons["station-us-kexp"].exists)
        XCTAssertTrue(app.buttons["station-us-kuow"].exists)
        XCTAssertFalse(app.buttons["station-wnyc"].exists)
        capture(app, "Seattle station search")
        app.buttons["station-us-kexp"].tap()
        let play = app.buttons["play-pause"]
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: play)
        waitForExpectations(timeout: 30)
        play.tap()
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "KUOW")
        XCTAssertTrue(app.buttons["open-stations"].label.contains("Seattle"))
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "KEXP")
        app.toggleCurrentFavorite()
        app.openAllStations()
        search.tap()
        search.typeText("Los Angeles")
        XCTAssertTrue(app.buttons["station-us-kcrw"].exists)
        XCTAssertTrue(app.buttons["station-us-kusc"].exists)
        app.buttons["station-us-kcrw"].tap()
        play.tap()
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "Classical KUSC")
        XCTAssertTrue(app.buttons["open-stations"].label.contains("Los Angeles"))
        capture(app, "Los Angeles local dial")
        app.terminate()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertEqual(app.buttons["open-station-info"].label, "Classical KUSC")
        app.openFavorites()
        XCTAssertTrue(app.buttons["station-us-kexp"].exists)
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = name
        image.lifetime = .keepAlways
        add(image)
    }
}
