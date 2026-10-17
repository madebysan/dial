import XCTest

final class MotionUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testMotionControlsAndRapidReversal() { exerciseMotion(reduced: false) }
    func testReducedMotionKeepsEveryControlUsable() { exerciseMotion(reduced: true) }

    private func exerciseMotion(reduced: Bool) {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        if reduced { app.launchArguments.append("--reduce-motion") }
        app.launch()
        app.buttons["play-pause"].tap()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        app.buttons["open-station-info"].tap()
        let favorite = app.buttons["favorite-toggle"]
        mark("favorite-on", reduced)
        favorite.tap()
        XCTAssertEqual(favorite.label, "Remove favorite")
        mark("favorite-rapid-reversal", reduced)
        favorite.tap()
        favorite.tap()
        XCTAssertEqual(favorite.label, "Remove favorite")
        favorite.tap()
        XCTAssertEqual(favorite.label, "Add favorite")
        favorite.tap()
        XCTAssertEqual(favorite.label, "Remove favorite")
        app.buttons["close-station-info"].tap()
        mark("play-pause-reversal", reduced)
        app.buttons["play-pause"].tap()
        app.buttons["play-pause"].tap()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")

        app.buttons["open-station-info"].tap()
        app.scrollViews["station-info-scroll"].swipeUp()
        let details = app.buttons["Sources & stream details"]
        mark("details-reversal", reduced)
        details.tap()
        details.tap()
        XCTAssertFalse(app.staticTexts["Profile quality"].exists)
        details.tap()
        XCTAssertTrue(app.staticTexts["Profile quality"].waitForExistence(timeout: 5))
        details.tap()
        XCTAssertFalse(app.staticTexts["Profile quality"].exists)
        app.buttons["close-station-info"].tap()

        app.openAllStations()
        let layout = app.buttons["toggle-station-layout"]
        mark("layout-reversal", reduced)
        layout.tap()
        layout.tap()
        XCTAssertTrue(app.scrollViews["station-grid"].exists)
        layout.tap()
        XCTAssertTrue(app.collectionViews["station-list"].exists)
        app.buttons["save-wbgo"].tap()
        XCTAssertEqual(app.buttons["save-wbgo"].label, "Unsave WBGO")
        app.buttons["save-wbgo"].tap()
        XCTAssertEqual(app.buttons["save-wbgo"].label, "Save WBGO")
        layout.tap()
        XCTAssertTrue(app.scrollViews["station-grid"].exists)
        app.buttons["Done"].tap()

        app.buttons["open-settings"].tap()
        app.buttons["sleep-15"].tap()
        let duration = app.buttons["Change duration"]
        mark("timer-reversal", reduced)
        duration.tap()
        duration.tap()
        XCTAssertFalse(app.buttons["sleep-30"].exists)
        duration.tap()
        XCTAssertTrue(app.buttons["sleep-30"].waitForExistence(timeout: 5))
        app.buttons["sleep-30"].tap()
        XCTAssertFalse(app.buttons["sleep-15"].exists)
        app.buttons["cancel-sleep-timer"].tap()
        XCTAssertTrue(app.buttons["sleep-15"].exists)
        app.buttons["Done"].tap()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        mark("restore-saved-station", reduced)
        app.buttons["next-station"].tap()
        app.buttons["open-station-info"].tap()
        XCTAssertEqual(app.buttons["favorite-toggle"].label, "Add favorite")
        app.buttons["close-station-info"].tap()
        app.buttons["previous-station"].tap()
        app.buttons["open-station-info"].tap()
        XCTAssertEqual(app.buttons["favorite-toggle"].label, "Remove favorite")
        app.buttons["close-station-info"].tap()
    }

    func testFailureFeedbackRemainsImmediate() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state", "--fail-stream"]
        app.launch()
        let play = app.buttons["play-pause"]
        expectation(for: NSPredicate(format: "label == %@", "Retry playback"), evaluatedWith: play)
        waitForExpectations(timeout: 25)
        app.toggleCurrentFavorite()
        app.toggleCurrentFavorite()
        app.buttons["open-station-info"].tap()
        XCTAssertEqual(app.buttons["favorite-toggle"].label, "Add favorite")
        app.buttons["close-station-info"].tap()
        app.buttons["next-station"].tap()
        XCTAssertEqual(play.label, "Play")
    }

    private func mark(_ step: String, _ reduced: Bool) {
        print("MOTION_MARK \(reduced ? "reduced" : "standard") \(step) \(Date().timeIntervalSince1970)")
    }
}
