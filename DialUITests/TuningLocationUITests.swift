import XCTest

final class TuningLocationUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testMinneapolisSelectionShowsTheActualTuningScope() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.openAllStations()
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("MPR News")
        app.buttons["station-us-know"].tap()
        XCTAssertTrue(app.buttons["open-stations"].label.contains("Minneapolis–Saint Paul"))
        XCTAssertTrue(app.buttons["open-stations"].label.contains("2 FM stations in Dial"))
        capture(app, "Minneapolis scope with two FM stations")
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "The Current")
        app.buttons["next-station"].tap()
        XCTAssertEqual(app.buttons["open-station-info"].label, "MPR News")
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let item = XCTAttachment(screenshot: app.screenshot())
        item.name = name
        item.lifetime = .keepAlways
        add(item)
    }

    func testCountryPickerOffersCitiesAndCountryWideOnline() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.buttons["play-pause"].tap()
        app.openAllStations()
        app.filterStations(country: "newYork", location: "newYork-Minneapolis–Saint Paul")
        XCTAssertTrue(app.buttons["city-filter"].label.contains("Minneapolis–Saint Paul"))
        capture(app, "Minneapolis stations")
        app.chooseStation("us-know")
        XCTAssertTrue(app.buttons["open-stations"].label.contains("Minneapolis–Saint Paul"))
        app.buttons["open-stations"].tap()
        XCTAssertTrue(app.buttons["city-filter"].label.contains("Minneapolis–Saint Paul"))
        app.filterStations(country: "newYork", location: "newYork-online")
        XCTAssertTrue(app.buttons["city-filter"].label.contains("Other stations"))
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'station-'")).firstMatch.tap()
        XCTAssertTrue(app.buttons["open-stations"].label.contains("Other stations"))
        XCTAssertTrue(app.buttons["open-stations"].label.contains("9 stations in Dial"))
        XCTAssertFalse(app.otherElements["tuning-dial"].exists)
        capture(app, "Country-wide Online collection")
    }

    func testWorldwideSearchKeepsDuplicateFrequenciesDistinct() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.openAllStations()
        app.buttons["toggle-station-layout"].tap()
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("91.1")
        XCTAssertTrue(app.buttons["station-wfmu"].exists)
        XCTAssertTrue(app.buttons["station-us-know"].exists)
        XCTAssertEqual(app.staticTexts["location-wfmu"].label, "United States · Jersey City")
        XCTAssertEqual(app.staticTexts["location-us-know"].label, "United States · Minneapolis–Saint Paul")
        capture(app, "Same frequency with distinct city labels")
        app.buttons["station-wfmu"].tap()
        XCTAssertTrue(app.buttons["open-stations"].label.contains("New York metro"))
        app.terminate()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["open-stations"].label.contains("New York metro"))
        XCTAssertEqual(app.buttons["open-station-info"].label, "WFMU")
    }
}
