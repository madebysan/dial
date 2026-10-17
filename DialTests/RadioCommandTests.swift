import XCTest
@testable import Dial

final class RadioCommandTests: XCTestCase {
    func testOnlySupportedDeepLinksBecomeCommands() {
        XCTAssertEqual(PlaybackCommands.action(for: URL(string: "dialradio://station/wnyc")!), .station("wnyc"))
        XCTAssertEqual(PlaybackCommands.action(for: URL(string: "dialradio://pause")!), .pause)
        XCTAssertNil(PlaybackCommands.action(for: URL(string: "https://example.com/station/wnyc")!))
        XCTAssertNil(PlaybackCommands.action(for: URL(string: "dialradio://station")!))
        XCTAssertNil(PlaybackCommands.action(for: URL(string: "dialradio://station/a/b")!))
    }

    @MainActor func testExplicitCommandsOverrideAutoplayOffAndPauseStaysPaused() {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(false, forKey: "autoplayOnOpen")
        let radio = RadioPlayer(library: Library(stations: seedStations, defaults: defaults),
                                streamOverride: URL(string: "https://127.0.0.1:1/unavailable")!, defaults: defaults)
        radio.volume = 0
        radio.tuningSoundEnabled = false
        defer { radio.pause() }
        XCTAssertTrue(radio.handleCommand(.station("wfmu")))
        XCTAssertEqual(radio.selected.id, "wfmu")
        XCTAssertTrue(radio.isActive)
        XCTAssertTrue(radio.handleCommand(.pause))
        radio.becameActive()
        XCTAssertEqual(radio.state, .paused)
        XCTAssertFalse(radio.handleCommand(.station("missing")))
        XCTAssertEqual(radio.selected.id, "wfmu")
    }

    func testStationQueryResolvesStableIDsAndSearches() async throws {
        let query = RadioStationQuery()
        let resolved = try await query.entities(for: ["wnyc", "does-not-exist"])
        XCTAssertEqual(resolved.map(\.id), ["wnyc"])
        let matches = try await query.entities(matching: "WNYC")
        XCTAssertTrue(matches.contains { $0.id == "wnyc" })
    }

    @MainActor func testPendingCommandCannotBeClearedByAnOlderRequest() {
        let commands = PlaybackCommands()
        commands.request(.resume)
        let first = commands.pending!.id
        commands.request(.pause)
        commands.clear(first)
        XCTAssertEqual(commands.pending?.action, .pause)
        commands.clear(commands.pending!.id)
        XCTAssertNil(commands.pending)
    }

}
