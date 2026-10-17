import XCTest
@testable import Dial

@MainActor
final class SavedItemsTests: XCTestCase {
    private func withDefaults(_ body: (UserDefaults) throws -> Void) rethrows {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        try body(defaults)
    }

    func testTitlesPersistWithoutExactDuplicatesAndCanBeRemoved() throws {
        try withDefaults { defaults in
            let store = SavedItems(defaults: defaults)
            XCTAssertTrue(try store.saveTitle("Artist — Song", station: seedStations[0]))
            XCTAssertFalse(try store.saveTitle("  ARTIST   — Song  ", station: seedStations[1]))
            let restored = SavedItems(defaults: defaults)
            XCTAssertEqual(restored.titles.count, 1)
            XCTAssertEqual(restored.titles[0].title, "Artist — Song")
            try restored.removeTitles([restored.titles[0].id])
            XCTAssertTrue(SavedItems(defaults: defaults).titles.isEmpty)
        }
    }

    func testUnreadableSavedDataIsNeverOverwritten() throws {
        try withDefaults { defaults in
            let corrupt = Data("not json".utf8)
            defaults.set(corrupt, forKey: "savedTitles")
            let store = SavedItems(defaults: defaults)
            XCTAssertNotNil(store.storageIssue)
            XCTAssertThrowsError(try store.saveTitle("Artist — Song", station: seedStations[0]))
            XCTAssertEqual(defaults.data(forKey: "savedTitles"), corrupt)
        }
    }

    func testMusicSearchLinksEncodeTheCompleteTitle() throws {
        let title = "Artist & Guest / Song?#%"
        let apple = try XCTUnwrap(MusicSearch.appleMusic.url(for: title))
        let tidal = try XCTUnwrap(MusicSearch.tidal.url(for: title))
        XCTAssertEqual(URLComponents(url: apple, resolvingAgainstBaseURL: false)?.queryItems?.first?.value, title)
        XCTAssertEqual(URLComponents(url: tidal, resolvingAgainstBaseURL: false)?.queryItems?.first?.value, title)
        let spotify = try XCTUnwrap(MusicSearch.spotify.url(for: title))
        XCTAssertEqual(spotify.host, "open.spotify.com")
        XCTAssertTrue(spotify.absoluteString.contains("%2F"))
        XCTAssertNil(spotify.query)
        XCTAssertNil(spotify.fragment)
        XCTAssertNil(MusicSearch.appleMusic.url(for: "  "))
    }
}
