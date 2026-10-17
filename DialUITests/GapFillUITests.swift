import XCTest

final class GapFillUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testAddedStationsAndRepairedArtwork() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        for (query, id, name) in [
            ("Radio Paradise", "us-radio-paradise", "Radio Paradise"),
            ("ESPN", "us-espn", "ESPN Radio 1050"),
            ("Times Radio", "gb-times", "Times Radio"),
            ("Radio 5", "es-radio5", "Radio 5"),
            ("Radio Clásica", "es-radio-clasica", "Radio Clásica")
        ] {
            app.openAllStations()
            let search = app.searchFields.firstMatch
            search.tap()
            search.typeText(query)
            let station = app.buttons["station-\(id)"]
            XCTAssertTrue(station.waitForExistence(timeout: 5))
            station.tap()
            XCTAssertEqual(app.buttons["open-station-info"].label, name)
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = "Gap fill - \(name)"
            screenshot.lifetime = .keepAlways
            add(screenshot)
            app.buttons["open-station-info"].tap()
            XCTAssertTrue(app.buttons["favorite-toggle"].exists)
            app.buttons["close-station-info"].tap()
        }
    }
}
