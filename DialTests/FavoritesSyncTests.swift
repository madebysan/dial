import XCTest
@testable import Dial

/// Stands in for iCloud key-value storage: `remote` is what iCloud holds for the account.
private final class FakeCloud: FavoritesCloudStore {
    var remote: [String]?
    var writes = 0
    var onExternalChange: ((FavoritesCloudChange) -> Void)?

    init(_ remote: [String]? = nil) { self.remote = remote }
    func favoriteIDs() -> [String]? { remote }
    func setFavoriteIDs(_ ids: [String]) { remote = ids; writes += 1 }

    /// Another device (or iCloud's first download) changes the list.
    func receive(_ ids: [String], _ change: FavoritesCloudChange) {
        remote = ids
        onExternalChange?(change)
    }
}

final class FavoritesSyncTests: XCTestCase {
    private var suites: [String] = []

    override func tearDown() {
        suites.forEach { UserDefaults().removePersistentDomain(forName: $0) }
        super.tearDown()
    }

    private func defaults(favorites: [String] = []) -> UserDefaults {
        let name = "FavoritesSyncTests.\(UUID().uuidString)"
        suites.append(name)
        let defaults = UserDefaults(suiteName: name)!
        if !favorites.isEmpty { defaults.set(favorites, forKey: "favorites") }
        return defaults
    }

    func testFirstSyncMergesThisDeviceWithICloud() {
        let cloud = FakeCloud(["wqxr"])
        let library = Library(defaults: defaults(favorites: ["wnyc"]), cloud: cloud)
        XCTAssertEqual(library.favoriteIDs, ["wnyc", "wqxr"])
        XCTAssertEqual(cloud.remote, ["wnyc", "wqxr"])
    }

    func testEmptyNewDeviceDoesNotOverwriteICloudAndAdoptsItsFirstDownload() {
        let cloud = FakeCloud()
        let library = Library(defaults: defaults(), cloud: cloud)
        XCTAssertNil(cloud.remote, "An empty device must not write an empty list over another device's favorites")
        cloud.receive(["wbgo", "wfuv"], .joined)
        XCTAssertEqual(library.favoriteIDs, ["wbgo", "wfuv"])
    }

    func testFavoritesMadeBeforeTheFirstDownloadSurviveIt() {
        let cloud = FakeCloud()
        let library = Library(defaults: defaults(), cloud: cloud)
        library.toggleFavorite(library.stations.first { $0.id == "wnyc" }!)
        XCTAssertEqual(cloud.remote, ["wnyc"])
        // iCloud's initial download replaces the local value and reports a join.
        cloud.receive(["wqxr"], .joined)
        XCTAssertEqual(library.favoriteIDs, ["wnyc", "wqxr"])
        XCTAssertEqual(cloud.remote, ["wnyc", "wqxr"])
    }

    func testAfterJoiningRemovalsOnAnotherDeviceApplyHere() {
        let store = defaults(favorites: ["wnyc", "wqxr"])
        let cloud = FakeCloud(["wnyc", "wqxr"])
        let library = Library(defaults: store, cloud: cloud)
        cloud.receive(["wqxr"], .edited)
        XCTAssertEqual(library.favoriteIDs, ["wqxr"])
        XCTAssertEqual(store.stringArray(forKey: "favorites"), ["wqxr"])

        // The next launch adopts iCloud's list too, instead of merging the removal back in.
        cloud.remote = ["wbgo"]
        let relaunched = Library(defaults: store, cloud: cloud)
        XCTAssertEqual(relaunched.favoriteIDs, ["wbgo"])
    }

    func testLocalChangesReachICloudAndKeepUnknownStations() {
        // "future-station" exists only in a newer catalogue on another device.
        let cloud = FakeCloud(["wnyc", "future-station"])
        let library = Library(defaults: defaults(favorites: ["wnyc"]), cloud: cloud)
        XCTAssertEqual(library.favoriteIDs, ["wnyc"])
        library.toggleFavorite(library.stations.first { $0.id == "wqxr" }!)
        XCTAssertEqual(cloud.remote, ["future-station", "wnyc", "wqxr"])
        library.toggleFavorite(library.stations.first { $0.id == "wnyc" }!)
        XCTAssertEqual(cloud.remote, ["future-station", "wqxr"])
    }

    func testAccountChangeMergesInsteadOfReplacing() {
        let cloud = FakeCloud(["wnyc"])
        let library = Library(defaults: defaults(favorites: ["wnyc"]), cloud: cloud)
        cloud.receive(["wfmu"], .joined)
        XCTAssertEqual(library.favoriteIDs, ["wnyc", "wfmu"])
        XCTAssertEqual(cloud.remote, ["wfmu", "wnyc"])
    }

    func testWithoutICloudFavoritesStayLocal() {
        let store = defaults()
        let library = Library(defaults: store)
        library.toggleFavorite(library.stations.first { $0.id == "wnyc" }!)
        XCTAssertEqual(store.stringArray(forKey: "favorites"), ["wnyc"])
    }
}
