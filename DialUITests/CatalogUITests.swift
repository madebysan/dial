import XCTest

final class CatalogUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testEveryImportedStationPlaysInNativePlayer() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        let groups = [
            ("argentina", ["ar-la100", "ar-aspen", "ar-metro", "ar-mitre", "ar-rockandpop"]),
            ("spain", ["es-los40", "es-ser", "es-cadena100", "es-kissfm", "es-cadenadial"])
        ]
        for (region, ids) in groups {
            app.chooseCountry(region, station: ids[0])
            for id in ids {
                app.buttons["open-stations"].tap()
                app.filterStations(country: region)
                if id == ids.first { capture(app, "\(region) catalogue grid") }
                XCTAssertFalse(app.buttons["info-\(id)"].exists)
                XCTAssertFalse(app.buttons["save-\(id)"].exists)
                app.chooseStation(id)
                let status = app.buttons["play-pause"]
                expectation(for: NSPredicate(format: "value == %@", "playing"), evaluatedWith: status)
                waitForExpectations(timeout: 30)
                // Both groups are on a local FM dial: Buenos Aires and, since Oct 18, 2026, Madrid.
                XCTAssertTrue(app.otherElements["tuning-dial"].exists)
                if id == "es-los40" || id == "ar-metro" { capture(app, "\(id) playing") }
            }
        }
    }

    func testExpandedProfilesAndFavoritesSurviveRelaunch() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.toggleCurrentFavorite()
        app.chooseCountry("spain", station: "es-ser")
        app.openAllStations()
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("LOS40")
        app.buttons["station-es-los40"].tap()
        app.toggleCurrentFavorite()
        app.openAllStations()
        app.buttons["toggle-station-layout"].tap()
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("LOS40")
        app.buttons["info-es-los40"].tap()
        XCTAssertEqual(app.staticTexts["profile-name"].label, "LOS40")
        XCTAssertTrue(app.staticTexts["Spanish"].exists)
        capture(app, "LOS40 enriched profile")
        app.buttons["close-station-info"].tap()
        // Active search hides the library toolbar until its close control is used.
        app.buttons["close"].tap()
        app.buttons["Done"].tap()
        app.terminate()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertEqual(app.buttons["open-station-info"].label, "LOS40")
        app.openFavorites()
        XCTAssertTrue(app.buttons["station-wnyc"].exists)
        XCTAssertTrue(app.buttons["station-es-los40"].exists)
        app.buttons["station-wnyc"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "WNYC")
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
