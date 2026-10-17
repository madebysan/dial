import XCTest

final class DialUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
    }

    func testStationProfilesDoNotChangePlaybackAndShowDataGaps() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        app.openAllStations()
        app.buttons["toggle-station-layout"].tap()
        app.buttons["info-wbgo"].tap()
        XCTAssertTrue(app.staticTexts["profile-name"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["profile-name"].label, "WBGO")
        let overview = XCTAttachment(screenshot: app.screenshot())
        overview.name = "WBGO enriched profile"
        overview.lifetime = .keepAlways
        add(overview)
        let details = app.scrollViews["station-info-scroll"]
        details.swipeUp()
        app.buttons["Sources & stream details"].tap()
        XCTAssertTrue(app.staticTexts["Profile quality"].exists)
        let quality = XCTAttachment(screenshot: app.screenshot())
        quality.name = "WBGO profile sources and quality"
        quality.lifetime = .keepAlways
        add(quality)
        app.buttons["close-station-info"].tap()
        XCTAssertTrue(app.buttons["info-wbgo"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WNYC")
        XCTAssertEqual(app.buttons["play-pause"].label, "Pause")

        app.chooseCountry("montevideo", station: "futura")
        app.buttons["open-stations"].tap()
        app.buttons["info-futura"].tap()
        XCTAssertEqual(app.staticTexts["profile-name"].label, "Futura")
        details.swipeUp()
        XCTAssertGreaterThan(app.staticTexts.matching(NSPredicate(format: "label == %@", "Not supplied")).count, 0)
        let gaps = XCTAttachment(screenshot: app.screenshot())
        gaps.name = "Futura profile with missing fields"
        gaps.lifetime = .keepAlways
        add(gaps)
        app.buttons["close-station-info"].tap()
        app.buttons["info-elpuente"].tap()
        XCTAssertEqual(app.staticTexts["profile-name"].label, "El Puente")
        let fallback = XCTAttachment(screenshot: app.screenshot())
        fallback.name = "El Puente profile without artwork"
        fallback.lifetime = .keepAlways
        add(fallback)
    }

    func testAutoplayOnOpenAndForegroundAndPausedFavorite() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        let status = app.buttons["play-pause"]
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
        waitForExpectations(timeout: 25)
        let readout = XCTAttachment(screenshot: app.screenshot())
        readout.name = "Frequency 93.9 without clipping"
        readout.lifetime = .keepAlways
        add(readout)
        app.toggleCurrentFavorite()
        app.buttons["play-pause"].tap()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        app.openFavorites()
        app.buttons["station-wnyc"].tap()
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
        waitForExpectations(timeout: 25)
        app.buttons["play-pause"].tap()
        XCUIDevice.shared.press(.home)
        app.activate()
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
        waitForExpectations(timeout: 25)
        app.buttons["play-pause"].tap()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
    }

    func testMontevideoLocationPlaysAndRestoresSeparateDial() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        app.buttons["previous-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WFMU")
        app.buttons["play-pause"].tap()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        app.chooseCountry("montevideo", station: "futura")
        XCTAssertEqual(app.buttons["open-station-info"].label, "Futura")
        XCTAssertTrue(app.buttons["open-stations"].label.contains("Uruguay"))
        let status = app.buttons["play-pause"]
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
        waitForExpectations(timeout: 25)
        app.toggleCurrentFavorite()
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "Diamante")
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
        waitForExpectations(timeout: 25)
        app.chooseCountry("newYork", station: "wfmu")
        XCTAssertEqual(app.buttons["open-station-info"].label, "WFMU")
        app.buttons["play-pause"].tap()
        app.openFavorites()
        app.buttons["station-futura"].tap()
        XCTAssertTrue(app.buttons["open-stations"].label.contains("Uruguay"))
        XCTAssertEqual(app.buttons["open-station-info"].label, "Futura")
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
        waitForExpectations(timeout: 25)
        app.buttons["play-pause"].tap()
        app.terminate()
        app.launchArguments = ["--seed-catalog", "--ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["open-stations"].label.contains("Uruguay"))
        XCTAssertEqual(app.buttons["open-station-info"].label, "Futura")
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
        waitForExpectations(timeout: 25)
    }

    func testSearchAndSwitchDuringPlayback() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        let status = app.buttons["play-pause"]
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
        waitForExpectations(timeout: 25)
        app.openAllStations()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("WFMU")
        XCTAssertTrue(app.buttons["station-wfmu"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["station-wbgo"].exists)
        app.buttons["station-wfmu"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WFMU")
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
        waitForExpectations(timeout: 25)
        app.buttons["play-pause"].tap()
    }

    func testFavoritesPersistAndStationPickerPlaysLiveAudio() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        XCTAssertTrue(app.buttons["open-stations"].waitForExistence(timeout: 5))
        app.openAllStations()
        app.buttons["toggle-station-layout"].tap()
        let save = app.buttons["save-wfuv"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        save.tap()
        app.buttons["station-wfuv"].tap()
        XCTAssertTrue(app.buttons["open-station-info"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["open-station-info"].label, "WFUV")
        let live = NSPredicate(format: "value == %@", "playing")
        expectation(for: live, evaluatedWith: app.buttons["play-pause"])
        waitForExpectations(timeout: 25)
        app.buttons["play-pause"].tap()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        app.terminate()
        app.launchArguments = ["--seed-catalog", "--ui-testing"]
        app.launch()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WFUV")
        app.openFavorites()
        XCTAssertTrue(app.buttons["station-wfuv"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["station-wnyc"].exists)
    }

    func testDialAndSeekPreserveManualPause() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        app.buttons["play-pause"].tap()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WQXR")
        let readout = XCTAttachment(screenshot: app.screenshot())
        readout.name = "Frequency 105.9 without clipping"
        readout.lifetime = .keepAlways
        add(readout)
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WBGO")
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        let dial = app.otherElements["tuning-dial"]
        let start = dial.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5))
        let end = dial.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        XCTAssertNotEqual(app.buttons["open-station-info"].label, "WBGO")
    }

    func testFailedStreamOffersRetryAndCanSwitchStation() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state", "--fail-stream"]
        app.launch()
        let retry = app.buttons.matching(identifier: "play-pause").element
        expectation(for: NSPredicate(format: "label == %@", "Retry playback"), evaluatedWith: retry)
        waitForExpectations(timeout: 25)
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WQXR")
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
    }
}
