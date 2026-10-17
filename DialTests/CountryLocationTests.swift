import XCTest
@testable import Dial

@MainActor
final class CountryLocationTests: XCTestCase {
    /// App Review found the button stuck on a Mac with Location Services off: no prompt, no callback.
    func testLocationServicesOffFailsWithMessageInsteadOfSpinning() async throws {
        let locator = CountryLocation(servicesEnabled: { false }, waitLimit: .seconds(30))
        locator.request()
        XCTAssertTrue(locator.isLoading)
        for _ in 0..<50 where locator.isLoading { try await Task.sleep(for: .milliseconds(20)) }
        XCTAssertFalse(locator.isLoading)
        XCTAssertEqual(locator.message, CountryLocation.servicesOffMessage)
        XCTAssertNil(locator.countryCode)
    }

    func testCancelStopsTheRequest() {
        let locator = CountryLocation(servicesEnabled: { false })
        locator.request()
        locator.cancel()
        XCTAssertFalse(locator.isLoading)
        XCTAssertNil(locator.message)
    }
}
