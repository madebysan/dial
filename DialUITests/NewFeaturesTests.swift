import XCTest

final class NewFeaturesTests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testPausedPlayerAndVolumePopover() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.buttons["play-pause"].tap()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        XCTAssertFalse(app.staticTexts["Paused"].exists)
        XCTAssertFalse(app.sliders["volume"].exists)
        let button = app.buttons["open-volume"]
        let settings = app.buttons["open-settings"]
        XCTAssertLessThan(button.frame.midX, settings.frame.midX)
        XCTAssertFalse(app.buttons["open-favorites"].exists)
        XCTAssertEqual(button.frame.midY, settings.frame.midY, accuracy: 2)
        capture(app, "Simplified paused player")
        button.tap()
        let slider = app.sliders["volume"]
        XCTAssertTrue(slider.waitForExistence(timeout: 5))
        slider.adjust(toNormalizedSliderPosition: 0.35)
        let adjustedValue = slider.value as? String
        XCTAssertNotEqual(adjustedValue, "0%")
        capture(app, "Volume popover")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.08, dy: 0.65)).tap()
        XCTAssertFalse(slider.exists)
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        button.tap()
        XCTAssertEqual(slider.value as? String, adjustedValue)
        slider.adjust(toNormalizedSliderPosition: 0)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.08, dy: 0.65)).tap()
        app.buttons["open-settings"].tap()
        app.buttons["Dark"].tap()
        app.buttons["Done"].tap()
        button.tap()
        capture(app, "Dark volume popover")
    }

    func testPlayerInfoShowsCurrentStationWithoutChangingPlayback() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        waitForPlayback(app)
        let info = app.buttons["open-station-info"]
        XCTAssertFalse(app.buttons["favorite-toggle"].exists)
        capture(app, "Player with station info")
        info.tap()
        XCTAssertEqual(app.staticTexts["profile-name"].label, "WNYC")
        capture(app, "Station info bottom sheet")
        app.buttons["close-station-info"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WNYC")
        XCTAssertEqual(app.buttons["play-pause"].label, "Pause")
        app.buttons["play-pause"].tap()
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WQXR")
        info.tap()
        XCTAssertEqual(app.staticTexts["profile-name"].label, "WQXR")
        app.buttons["close-station-info"].tap()
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
    }

    func testPlayerNavigationPlacementAndOnlineLabel() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        let stations = app.buttons["open-stations"]
        XCTAssertFalse(app.buttons["open-locations"].exists)
        XCTAssertTrue(stations.label.contains("New York metro"))
        XCTAssertLessThan(app.buttons["open-volume"].frame.maxY, stations.frame.minY)
        XCTAssertLessThan(app.buttons["open-settings"].frame.maxY, stations.frame.minY)
        XCTAssertEqual(stations.frame.midX, app.frame.midX, accuracy: 4)
        capture(app, "Player navigation")
        stations.tap()
        XCTAssertTrue(app.buttons["city-filter"].label.contains("New York metro"))
        app.buttons["Done"].tap()
        app.buttons["select-band"].tap()
        XCTAssertTrue(app.buttons["FM"].exists)
        XCTAssertTrue(app.buttons["AM"].exists)
        XCTAssertTrue(app.buttons["Other stations"].exists)
        XCTAssertFalse(app.buttons["Live"].exists)
        capture(app, "FM AM Online menu")
        app.buttons["Other stations"].tap()
        XCTAssertTrue(app.buttons["open-station-artwork"].exists)
    }

    func testGridListArtworkSelectionAndDarkSettings() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        app.openAllStations()
        XCTAssertTrue(app.scrollViews["station-grid"].exists)
        capture(app, "Station artwork grid")
        app.buttons["toggle-station-layout"].tap()
        XCTAssertEqual(app.buttons["toggle-station-layout"].label, "Show grid")
        app.buttons["toggle-station-layout"].tap()
        app.buttons["station-wfuv"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WFUV")
        waitForPlayback(app)
        app.buttons["open-settings"].tap()
        app.buttons["Dark"].tap()
        app.buttons["sleep-15"].tap()
        XCTAssertTrue(app.buttons["cancel-sleep-timer"].exists)
        capture(app, "Dark settings and sleep timer")
        app.buttons["cancel-sleep-timer"].tap()
        XCTAssertFalse(app.buttons["cancel-sleep-timer"].exists)
        app.buttons["Done"].tap()
        capture(app, "Dark player")
        app.openAllStations()
        capture(app, "Dark station artwork grid")
        app.buttons["Done"].tap()
        app.terminate()
        app.launchArguments = ["--seed-catalog", "--ui-testing"]
        app.launch()
        app.buttons["open-settings"].tap()
        XCTAssertTrue(app.buttons["Dark"].isSelected)
    }

    func testAMBandsPlayAndFMSelectionIsRestored() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        app.buttons["select-band"].tap()
        app.buttons["AM"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WABC")
        waitForPlayback(app)
        capture(app, "WABC AM tuner")
        app.buttons["select-band"].tap()
        app.buttons["FM"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WNYC")
        app.chooseCountry("montevideo", station: "futura")
        app.buttons["select-band"].tap()
        app.buttons["AM"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "Radio Clarín")
        waitForPlayback(app)
        capture(app, "Radio Clarín AM tuner")
    }

    func testLiveMetadataArrivesAndClearsOnPause() {
        let app = XCUIApplication()
        app.launchArguments = ["--seed-catalog", "--ui-testing", "--reset-state"]
        app.launch()
        app.openAllStations()
        app.buttons["station-wfuv"].tap()
        waitForPlayback(app)
        let title = app.buttons["live-title"]
        XCTAssertTrue(title.waitForExistence(timeout: 45))
        XCTAssertFalse(title.label.isEmpty)
        capture(app, "Live stream title")
        app.buttons["play-pause"].tap()
        XCTAssertFalse(title.exists)
        app.buttons["next-station"].tap()
        XCTAssertFalse(title.exists)
    }

    private func waitForPlayback(_ app: XCUIApplication) {
        let status = app.buttons["play-pause"]
        expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
        waitForExpectations(timeout: 30)
    }
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
