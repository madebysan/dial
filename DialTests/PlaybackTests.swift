import XCTest
@testable import Dial

final class PlaybackTests: XCTestCase {
    @MainActor func testAutoplayOffPreservesSilenceAcrossActivation() {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(false, forKey: "autoplayOnOpen")
        let radio = RadioPlayer(library: Library(stations: seedStations, defaults: defaults),
                                streamOverride: URL(string: "https://127.0.0.1:1/unavailable")!, defaults: defaults)
        radio.volume = 0
        radio.tuningSoundEnabled = false
        defer { radio.pause() }
        radio.becameActive()
        XCTAssertEqual(radio.state, .idle)
        radio.enteredBackground()
        radio.becameActive()
        XCTAssertEqual(radio.state, .idle)
        radio.play()
        XCTAssertTrue(radio.isActive, "An explicit Play action must still start playback")
        radio.pause()
        radio.enteredBackground()
        radio.becameActive()
        XCTAssertEqual(radio.state, .paused)
    }

    func testBandsHaveSeparateTuningAndPersistLastChoice() {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let library = Library(stations: seedStations, defaults: defaults)
        let fm = library.selected
        let am = library.preferredStation(band: .am)!
        XCTAssertEqual(am.frequencyText, "770")
        library.select(am)
        XCTAssertEqual(library.adjacent(1), am)
        XCTAssertEqual(library.dialStations.map(\.id), ["wabc"])
        XCTAssertEqual(library.preferredStation(band: .fm), fm)
        let restored = Library(stations: seedStations, defaults: defaults)
        XCTAssertEqual(restored.selected, am)
        XCTAssertEqual(restored.preferredStation(band: .fm), fm)
        XCTAssertEqual(fm.frequencyText, "93.9")
    }

    func testAutoplayDefaultsOnAndPersistsAnExplicitChoice() {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let preferences = Preferences(defaults: defaults)
        XCTAssertTrue(preferences.autoplayOnOpen)
        preferences.autoplayOnOpen = false
        XCTAssertFalse(Preferences(defaults: defaults).autoplayOnOpen)
        preferences.autoplayOnOpen = true
        XCTAssertTrue(Preferences(defaults: defaults).autoplayOnOpen)
    }

    func testAppearanceAndLayoutPersist() {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let preferences = Preferences(defaults: defaults)
        XCTAssertEqual(preferences.layout, .grid)
        preferences.layout = .list
        preferences.appearance = .dark
        let restored = Preferences(defaults: defaults)
        XCTAssertEqual(restored.layout, .list)
        XCTAssertEqual(restored.appearance, .dark)
    }

    @MainActor func testTimerReplacementCancellationAndExactlyOnceExpiry() {
        let timer = SleepTimer()
        let now = Date()
        var fired = 0
        timer.onExpire = { fired += 1 }
        timer.start(seconds: 900, now: now)
        XCTAssertFalse(timer.expireIfNeeded(now: now.addingTimeInterval(899)))
        timer.start(seconds: 1800, now: now)
        XCTAssertFalse(timer.expireIfNeeded(now: now.addingTimeInterval(901)))
        XCTAssertTrue(timer.expireIfNeeded(now: now.addingTimeInterval(1800)))
        XCTAssertFalse(timer.expireIfNeeded(now: now.addingTimeInterval(1801)))
        XCTAssertEqual(fired, 1)
        XCTAssertNil(timer.deadline)
        timer.start(seconds: 15, now: now)
        timer.cancel()
        XCTAssertFalse(timer.expireIfNeeded(now: now.addingTimeInterval(16)))
        XCTAssertEqual(fired, 1)
    }

    @MainActor func testTimerStopsPlaybackAndDoesNotAutoplayOnForeground() {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let radio = RadioPlayer(library: Library(stations: seedStations, defaults: defaults), defaults: defaults)
        radio.sleepTimer.start(seconds: 900)
        radio.sleepTimer.expireIfNeeded(now: .now.addingTimeInterval(901))
        XCTAssertEqual(radio.state, .paused)
        radio.enteredBackground()
        radio.becameActive()
        XCTAssertEqual(radio.state, .paused)
    }

    @MainActor func testRealTimerTaskFiresAndPauseCancelsRetry() async throws {
        let timer = SleepTimer()
        var fired = false
        timer.onExpire = { fired = true }
        timer.start(seconds: 0.05)
        try await Task.sleep(for: .milliseconds(150))
        XCTAssertTrue(fired)
        XCTAssertNil(timer.deadline)

        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let radio = RadioPlayer(library: Library(stations: seedStations, defaults: defaults),
                                streamOverride: URL(string: "https://127.0.0.1:1/unavailable")!, defaults: defaults)
        radio.play()
        try await Task.sleep(for: .milliseconds(300))
        radio.pause()
        try await Task.sleep(for: .seconds(2))
        XCTAssertEqual(radio.state, .paused)
        XCTAssertNil(radio.liveTitle)
    }

    func testStreamTitleCleanupPreservesBroadcasterText() {
        XCTAssertEqual(StreamMetadata.clean("  Artist – Song\nLive\0  "), "Artist – Song Live")
        XCTAssertNil(StreamMetadata.clean("  \n\0 "))
        XCTAssertEqual(StreamMetadata.clean(String(repeating: "x", count: 600))?.count, 500)
        // iHeartRadio streams append tags after the artist; keep only the artist and song.
        XCTAssertEqual(StreamMetadata.clean(#"Sombr - text="My Body Isn't Ready" song_spot="M" MediaBaseId="3238238" itunesTrackId="0" amgTrackId="-1""#),
                       "Sombr - My Body Isn't Ready")
        XCTAssertEqual(StreamMetadata.clean(#"text="Z100 Morning Show" song_spot="T" MediaBaseId="0""#), "Z100 Morning Show")
        XCTAssertEqual(StreamMetadata.clean("Artist - Song (Remix) feat. Guest"), "Artist - Song (Remix) feat. Guest")
    }
}
