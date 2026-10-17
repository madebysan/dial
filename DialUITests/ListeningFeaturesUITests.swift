import XCTest

final class ListeningFeaturesUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"] + extra
        app.launch()
        return app
    }
    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<7 {
            if element.isHittable { return }
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testUnsupportedCountryStartsInNewYorkAndChoiceIsRestored() {
        let app = launch(["--initial-country=ZZ"])
        XCTAssertTrue(app.buttons["play-pause"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["open-station-info"].label, "WNYC")
        XCTAssertTrue(app.buttons["open-stations"].label.contains("New York metro"))
        capture(app, "Unsupported region starts in New York")
        app.chooseCountry("montevideo", station: "futura")
        let station = app.buttons["open-station-info"].label
        app.terminate()
        app.launchArguments = ["--ui-testing", "--initial-country=US"]
        app.launch()
        XCTAssertEqual(app.buttons["open-station-info"].label, station)
    }

    func testApproximateLocationChoosesCountry() {
        let app = launch(["--initial-country=UY"])
        app.openAllStations()
        app.buttons["city-filter"].tap()
        app.buttons["detect-country"].tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allow = springboard.alerts.buttons["Allow While Using App"]
        if allow.waitForExistence(timeout: 5) {
            capture(springboard, "Approximate location permission")
            allow.tap()
        }
        let filter = app.buttons["city-filter"]
        expectation(for: NSPredicate(format: "label CONTAINS %@", "New York metro · United States"), evaluatedWith: filter)
        waitForExpectations(timeout: 30)
        app.chooseStation("wnyc")
        XCTAssertEqual(app.buttons["open-station-info"].label, "WNYC")
        capture(app, "Country resolved from simulated New York location")
    }

    func testPlaybackCommandsOpenStationAndPauseWhileClosingSettings() {
        let app = launch()
        app.buttons["open-settings"].tap()
        let shortcuts = app.buttons["open-shortcuts"]
        reveal(shortcuts, in: app)
        shortcuts.tap()
        XCTAssertTrue(app.staticTexts["Play station"].waitForExistence(timeout: 5))
        capture(app, "Siri and Shortcuts actions")
        app.open(URL(string: "dialradio://station/wfmu")!)
        XCTAssertTrue(app.buttons["open-station-info"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.buttons["open-station-info"].label, "WFMU")
        app.open(URL(string: "dialradio://pause")!)
        XCTAssertEqual(app.buttons["play-pause"].value as? String, "paused")
        XCUIDevice.shared.press(.home)
        app.open(URL(string: "dialradio://pause")!)
        XCTAssertEqual(app.buttons["play-pause"].value as? String, "paused")
        capture(app, "Playback command from background")
    }

    func testListeningSettingsPersistAndIconCanChangeAndRestore() {
        let app = launch()
        app.buttons["play-pause"].tap()
        app.buttons["open-settings"].tap()
        let haptics = app.switches["haptic-feedback"]
        haptics.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        let awake = app.switches["keep-awake"]
        awake.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        capture(app, "Listening preferences")
        app.buttons["open-narration"].tap()
        app.buttons["narration-mode"].tap()
        app.buttons["Headphones & Bluetooth"].tap()
        capture(app, "Station announcements")
        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["open-icon-picker"].tap()
        capture(app, "Four app icon choices")
        if app.buttons["icon-option-knob"].isEnabled {
            app.buttons["icon-option-knob"].tap()
            expectation(for: NSPredicate(format: "value == 'Selected'"), evaluatedWith: app.buttons["icon-option-knob"])
            waitForExpectations(timeout: 10)
        }
        app.buttons["icon-option-monogram"].tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.alerts.buttons["OK"].waitForExistence(timeout: 3) { springboard.alerts.buttons["OK"].tap() }
        expectation(for: NSPredicate(format: "value == 'Selected'"), evaluatedWith: app.buttons["icon-option-monogram"])
        waitForExpectations(timeout: 10)
        app.buttons["icon-option-knob"].tap()
        if springboard.alerts.buttons["OK"].waitForExistence(timeout: 3) { springboard.alerts.buttons["OK"].tap() }
        expectation(for: NSPredicate(format: "value == 'Selected'"), evaluatedWith: app.buttons["icon-option-knob"])
        waitForExpectations(timeout: 10)
        app.terminate()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        app.buttons["open-settings"].tap()
        XCTAssertEqual(haptics.value as? String, "0")
        XCTAssertEqual(awake.value as? String, "1")
        XCTAssertTrue(app.buttons["open-narration"].label.contains("Headphones & Bluetooth"))
    }

    func testNativeAlarmCreateDisableAndDelete() {
        let app = launch()
        app.buttons["play-pause"].tap()
        app.buttons["open-settings"].tap()
        let alarms = app.buttons["open-alarms"]
        reveal(alarms, in: app)
        alarms.tap()
        app.buttons["add-station-alarm"].tap()
        capture(app, "New station alarm")
        app.buttons["save-station-alarm"].tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.alerts.buttons["Allow"].waitForExistence(timeout: 5) { springboard.alerts.buttons["Allow"].tap() }
        let alarm = app.switches.matching(NSPredicate(format: "identifier BEGINSWITH 'station-alarm-'")).firstMatch
        XCTAssertTrue(alarm.waitForExistence(timeout: 10), app.debugDescription)
        capture(app, "Scheduled native alarm")
        alarm.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(alarm.value as? String, "0")
        alarm.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["No station alarms"].exists)
    }

    func testLiveTitleCanBeSavedAndMusicSearchesShown() {
        let app = launch()
        app.openAllStations()
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("KEXP")
        app.buttons["station-us-kexp"].tap()
        let title = app.buttons["live-title"]
        XCTAssertTrue(title.waitForExistence(timeout: 30))
        title.tap()
        app.buttons["save-current-title"].tap()
        XCTAssertEqual(app.buttons["save-current-title"].label, "Saved")
        XCTAssertTrue(app.buttons["Apple Music"].exists)
        XCTAssertTrue(app.buttons["Spotify"].exists)
        XCTAssertTrue(app.buttons["Tidal"].exists)
        capture(app, "Saved live title and music searches")
        app.buttons["Done"].tap()
        app.buttons["open-settings"].tap()
        let saved = app.buttons["open-saved-titles"]
        reveal(saved, in: app)
        saved.tap()
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'saved-title-'")).count, 1)
        capture(app, "Saved titles library")
    }
}
