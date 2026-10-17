import XCTest

final class SettingsUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { XCUIApplication().terminate() }

    func testAutoplayChoicePersistsAndAboutShowsBuildAndCredits() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-state"]
        app.launch()
        app.buttons["play-pause"].tap()
        app.buttons["open-settings"].tap()
        let autoplay = app.switches["autoplay-on-open"]
        XCTAssertEqual(autoplay.value as? String, "1")
        autoplay.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(autoplay.value as? String, "0")
        capture(app, "Autoplay off setting")

        let version = app.staticTexts["app-version"]
        for _ in 0..<3 {
            if version.isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(version.exists)
        let versionDescription = version.label + " " + (version.value as? String ?? "")
        XCTAssertNotNil(versionDescription.range(of: #"\d+\.\d+(\.\d+)? \(\d+\)"#, options: .regularExpression), versionDescription)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "catalog-source").firstMatch.exists)
        app.swipeUp()
        capture(app, "About version and station credits")
        app.buttons["Done"].tap()

        app.terminate()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertEqual(app.buttons["play-pause"].value as? String, "idle")
        XCTAssertEqual(app.buttons["play-pause"].label, "Play")
        capture(app, "Silent launch with autoplay off")
        app.buttons["open-settings"].tap()
        XCTAssertEqual(autoplay.value as? String, "0")
        autoplay.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(autoplay.value as? String, "1")
        app.buttons["Done"].tap()
        app.terminate()
        app.launch()
        XCTAssertNotEqual(app.buttons["play-pause"].value as? String, "idle")
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let image = XCTAttachment(screenshot: app.screenshot())
        image.name = name
        image.lifetime = .keepAlways
        add(image)
    }
}
