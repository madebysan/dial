import XCTest

final class UKExpansionUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testBBCNationalAndWelshServicesAndFavorites() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.openAllStations()
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("BBC Radio 1")
        XCTAssertEqual(app.staticTexts["station-count"].label, "4 stations")
        XCTAssertTrue(app.buttons["station-gb-bbc-radio-one"].exists)
        XCTAssertTrue(app.buttons["station-gb-bbc-radio-one-anthems"].exists)
        XCTAssertTrue(app.buttons["station-gb-bbc-radio-one-dance"].exists)
        XCTAssertTrue(app.buttons["station-gb-bbc-1xtra"].exists)
        capture(app, "BBC Radio 1 family")
        app.buttons["station-gb-bbc-radio-one"].tap()
        waitForPlayback(app)
        XCTAssertEqual(app.buttons["open-station-info"].label, "BBC Radio 1")
        XCTAssertFalse(app.staticTexts["station-city"].exists)
        capture(app, "BBC Radio 1 player")
        app.toggleCurrentFavorite()
        XCTAssertEqual(app.buttons["play-pause"].value as? String, "playing")
        app.openAllStations()
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("Cymru")
        XCTAssertEqual(app.staticTexts["station-count"].label, "2 stations")
        app.buttons["station-gb-bbc-radio-cymru"].tap()
        waitForPlayback(app)
        app.buttons["play-pause"].tap()
        app.buttons["open-station-info"].tap()
        XCTAssertEqual(app.staticTexts["profile-name"].label, "BBC Radio Cymru")
        app.scrollViews["station-info-scroll"].swipeUp()
        XCTAssertTrue(app.staticTexts["Welsh"].exists)
        capture(app, "BBC Welsh station details")
        app.buttons["close-station-info"].tap()
        app.terminate()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertEqual(app.buttons["open-station-info"].label, "BBC Radio Cymru")
        app.openFavorites()
        XCTAssertTrue(app.buttons["station-gb-bbc-radio-one"].exists)
    }

    func testBBCCoverageChannelIslandsAndLondonTuning() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.openAllStations()
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("BBC")
        XCTAssertEqual(app.staticTexts["station-count"].label, "66 stations")
        capture(app, "Full BBC search")
        search.typeText(" Radio Guernsey")
        app.buttons["station-gb-bbc-radio-guernsey"].tap()
        app.buttons["play-pause"].tap()
        app.buttons["open-station-info"].tap()
        XCTAssertTrue(app.staticTexts["Guernsey · Channel Islands"].exists)
        app.buttons["close-station-info"].tap()
        app.openAllStations()
        search.tap()
        search.typeText("London")
        capture(app, "Expanded London search")
        app.buttons["station-gb-smooth-london"].tap()
        app.buttons["play-pause"].tap()
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "Resonance FM")
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "Heart London")
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "Smooth London")
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        app.openAllStations()
        app.filterStations(country: "unitedKingdom")
        XCTAssertEqual(app.staticTexts["station-count"].label, "81 stations")
        capture(app, "UK collection count")
    }

    private func waitForPlayback(_ app: XCUIApplication) {
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: app.buttons["play-pause"])
        waitForExpectations(timeout: 30)
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
