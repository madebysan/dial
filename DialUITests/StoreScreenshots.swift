import XCTest

/// App Store capture. `scripts/store-screenshots/generate.sh` runs this, exports the named attachments and frames them.
/// Attachment names must match the `capture` keys in `scripts/store-screenshots/slots.json`.
/// Each slot starts from a fresh launch with reset state, so slots don't depend on each other.
final class StoreScreenshots: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    @MainActor
    func testCaptureStoreSet() {
        let player = launch()
        XCTAssertEqual(player.buttons["play-pause"].value as? String, "idle")
        capture(player, name: "player")

        let stations = launch()
        stations.openAllStations()
        XCTAssertTrue(stations.descendants(matching: .any)["station-grid"].waitForExistence(timeout: 5))
        capture(stations, name: "stations")

        let details = launch()
        details.buttons["open-station-info"].tap()
        XCTAssertTrue(details.staticTexts["profile-name"].waitForExistence(timeout: 5))
        XCTAssertEqual(details.staticTexts["profile-name"].label, "WNYC")
        capture(details, name: "details")

        let locations = launch()
        locations.buttons["open-stations"].tap()
        XCTAssertTrue(locations.buttons["city-filter"].waitForExistence(timeout: 5))
        capture(locations, name: "locations")

        let settings = launch()
        settings.buttons["open-settings"].tap()
        XCTAssertTrue(settings.switches["autoplay-on-open"].waitForExistence(timeout: 5))
        capture(settings, name: "settings")
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.terminate()
        // --screenshots keeps playback off so the player shows its idle state.
        app.launchArguments = ["--ui-testing", "--reset-state", "--screenshots", "--initial-country=US"]
        app.launch()
        XCTAssertTrue(app.buttons["play-pause"].waitForExistence(timeout: 10))
        return app
    }

    @MainActor
    private func capture(_ app: XCUIApplication, name: String) {
        // Give the compositor a settled full frame after sheet transitions and artwork loading.
        Thread.sleep(forTimeInterval: 2)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
