import XCTest

final class StationSheetUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testCadena3ArtworkAndNameOpenFavoriteSheet() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.openAllStations()
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("Cadena 3")
        app.buttons["station-ar-cadena3"].tap()
        let play = app.buttons["play-pause"]
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: play)
        waitForExpectations(timeout: 30)
        XCTAssertEqual(app.buttons["open-station-info"].label, "Cadena 3")
        XCTAssertEqual(app.staticTexts["station-city"].label, "Córdoba")
        XCTAssertFalse(app.staticTexts["Live stream · Argentina"].exists)
        XCTAssertFalse(app.staticTexts["Live from Córdoba"].exists)
        XCTAssertFalse(app.buttons["favorite-toggle"].exists)
        capture(app, "Cadena 3 clean player")
        app.buttons["open-station-artwork"].tap()
        XCTAssertEqual(app.staticTexts["profile-name"].label, "Cadena 3")
        app.buttons["favorite-toggle"].tap()
        XCTAssertEqual(app.buttons["favorite-toggle"].label, "Remove favorite")
        capture(app, "Cadena 3 station actions")
        app.buttons["close-station-info"].tap()
        XCTAssertEqual(play.value as? String, "playing")
        play.tap()
        XCTAssertEqual(app.staticTexts["station-city"].label, "Córdoba")
        app.buttons["open-station-info"].tap()
        XCTAssertEqual(app.buttons["favorite-toggle"].label, "Remove favorite")
        app.buttons["close-station-info"].tap()
        XCTAssertEqual(play.label, "Play")
        app.terminate()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        app.openFavorites()
        XCTAssertTrue(app.buttons["station-ar-cadena3"].exists)
        app.buttons["station-ar-cadena3"].tap()
        app.buttons["open-station-info"].tap()
        app.buttons["favorite-toggle"].tap()
        XCTAssertEqual(app.buttons["favorite-toggle"].label, "Add favorite")
    }

    func testFMNameAndUnselectedProfileUseTheCorrectStation() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        app.buttons["play-pause"].tap()
        XCTAssertFalse(app.buttons["open-station-artwork"].exists)
        XCTAssertFalse(app.buttons["favorite-toggle"].exists)
        app.buttons["open-station-frequency"].tap()
        XCTAssertEqual(app.staticTexts["profile-name"].label, "WNYC")
        XCTAssertTrue(app.buttons["favorite-toggle"].exists)
        capture(app, "Station sheet opened from frequency")
        app.buttons["close-station-info"].tap()
        app.toggleCurrentFavorite()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        XCTAssertEqual(app.buttons["open-station-info"].label, "WNYC")
        capture(app, "FM player with tappable name")
        app.openAllStations()
        app.buttons["toggle-station-layout"].tap()
        app.buttons["info-wbgo"].tap()
        XCTAssertEqual(app.staticTexts["profile-name"].label, "WBGO")
        XCTAssertEqual(app.buttons["favorite-toggle"].label, "Add favorite")
        app.buttons["favorite-toggle"].tap()
        app.buttons["close-station-info"].tap()
        app.buttons["Done"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WNYC")
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        app.openFavorites()
        XCTAssertTrue(app.buttons["station-wnyc"].exists)
        XCTAssertTrue(app.buttons["station-wbgo"].exists)
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = name
        image.lifetime = .keepAlways
        add(image)
    }
}
