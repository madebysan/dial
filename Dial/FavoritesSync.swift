import Foundation

/// Where favorites sync between a person's devices. Library owns the merge rules; the store only moves IDs.
protocol FavoritesCloudStore: AnyObject {
    /// `nil` when iCloud has never held favorites for this account.
    func favoriteIDs() -> [String]?
    func setFavoriteIDs(_ ids: [String])
    /// Called on the main queue when another device changed favorites, or the iCloud account changed.
    var onExternalChange: ((FavoritesCloudChange) -> Void)? { get set }
}

enum FavoritesCloudChange {
    /// Another device edited favorites: adopt them, including removals.
    case edited
    /// First download for this account, or a different account: merge, so neither side loses favorites.
    case joined
}

/// iCloud key-value storage. Without iCloud (signed out, or a build without the entitlement) it keeps
/// values on this device only, so favorites keep working locally.
final class UbiquitousFavoritesStore: FavoritesCloudStore {
    private let store = NSUbiquitousKeyValueStore.default
    private let key = "favorites"
    private var observer: NSObjectProtocol?
    var onExternalChange: ((FavoritesCloudChange) -> Void)?

    init() {
        observer = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: store, queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            let keys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []
            guard keys.contains(self.key) else { return }
            let reason = notification.userInfo?[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int
            let joined = reason == NSUbiquitousKeyValueStoreInitialSyncChange || reason == NSUbiquitousKeyValueStoreAccountChange
            self.onExternalChange?(joined ? .joined : .edited)
        }
        store.synchronize()
    }

    deinit { observer.map(NotificationCenter.default.removeObserver) }

    func favoriteIDs() -> [String]? { store.array(forKey: key) as? [String] }

    func setFavoriteIDs(_ ids: [String]) {
        store.set(ids, forKey: key)
        store.synchronize()
    }
}
