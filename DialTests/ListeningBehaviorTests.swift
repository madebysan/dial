import XCTest
#if os(iOS)
import UIKit
#endif
@testable import Dial

final class ListeningBehaviorTests: XCTestCase {
    #if os(iOS)
    func testKeepAwakeRequiresAllThreeConditions() {
        XCTAssertTrue(ListeningBehavior.shouldKeepAwake(enabled: true, isActive: true, batteryState: .charging))
        XCTAssertTrue(ListeningBehavior.shouldKeepAwake(enabled: true, isActive: true, batteryState: .full))
        XCTAssertFalse(ListeningBehavior.shouldKeepAwake(enabled: false, isActive: true, batteryState: .charging))
        XCTAssertFalse(ListeningBehavior.shouldKeepAwake(enabled: true, isActive: false, batteryState: .charging))
        XCTAssertFalse(ListeningBehavior.shouldKeepAwake(enabled: true, isActive: true, batteryState: .unplugged))
        XCTAssertFalse(ListeningBehavior.shouldKeepAwake(enabled: true, isActive: true, batteryState: .unknown))
    }
    #endif

    @MainActor func testNarrationRespectsModeAndVoiceOver() {
        XCTAssertFalse(StationNarrator.shouldAnnounce(mode: .off, headphones: true, voiceOver: false))
        XCTAssertFalse(StationNarrator.shouldAnnounce(mode: .headphones, headphones: false, voiceOver: false))
        XCTAssertTrue(StationNarrator.shouldAnnounce(mode: .headphones, headphones: true, voiceOver: false))
        XCTAssertTrue(StationNarrator.shouldAnnounce(mode: .always, headphones: false, voiceOver: false))
        XCTAssertFalse(StationNarrator.shouldAnnounce(mode: .always, headphones: true, voiceOver: true))
    }
}
