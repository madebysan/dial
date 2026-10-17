import Foundation
import Observation

struct SavedTitle: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let stationID: String
    let stationName: String
    let savedAt: Date
}

@MainActor @Observable
final class SavedItems {
    private(set) var titles: [SavedTitle] = []
    private(set) var storageIssue: String?
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var unreadableKeys: Set<String> = []

    enum StorageError: LocalizedError {
        case unreadable, emptyTitle
        var errorDescription: String? {
            switch self {
            case .unreadable: "Saved data could not be read. It has been kept unchanged."
            case .emptyTitle: "Enter a title first."
            }
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: "savedTitles") {
            do { titles = try JSONDecoder().decode([SavedTitle].self, from: data) }
            catch { unreadableKeys.insert("savedTitles"); storageIssue = StorageError.unreadable.localizedDescription }
        }
    }

    static func normalizedTitle(_ title: String) -> String {
        title.split(whereSeparator: \.isWhitespace).joined(separator: " ").lowercased()
    }

    func containsTitle(_ title: String) -> Bool {
        titles.contains { Self.normalizedTitle($0.title) == Self.normalizedTitle(title) }
    }

    @discardableResult
    func saveTitle(_ title: String, station: Station, now: Date = .now) throws -> Bool {
        let text = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw StorageError.emptyTitle }
        guard !containsTitle(text) else { return false }
        let updated = [SavedTitle(id: UUID(), title: text, stationID: station.id,
                                  stationName: station.name, savedAt: now)] + titles
        try persist(updated, key: "savedTitles")
        titles = updated
        return true
    }

    func removeTitles(_ ids: Set<UUID>) throws {
        let updated = titles.filter { !ids.contains($0.id) }
        try persist(updated, key: "savedTitles")
        titles = updated
    }

    private func persist<T: Encodable>(_ value: T, key: String) throws {
        guard !unreadableKeys.contains(key) else { throw StorageError.unreadable }
        defaults.set(try JSONEncoder().encode(value), forKey: key)
    }
}

enum MusicSearch: String, CaseIterable, Identifiable {
    case appleMusic = "Apple Music", spotify = "Spotify", tidal = "Tidal"
    var id: String { rawValue }

    func url(for title: String) -> URL? {
        let query = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return nil }
        var components = URLComponents()
        components.scheme = "https"
        switch self {
        case .appleMusic:
            components.host = "music.apple.com"
            components.path = "/search"
            components.queryItems = [URLQueryItem(name: "term", value: query)]
        case .spotify:
            components.host = "open.spotify.com"
            let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/%?#"))
            guard let encoded = query.addingPercentEncoding(withAllowedCharacters: allowed) else { return nil }
            components.percentEncodedPath = "/search/" + encoded
        case .tidal:
            components.host = "listen.tidal.com"
            components.path = "/search"
            components.queryItems = [URLQueryItem(name: "q", value: query)]
        }
        return components.url
    }
}

enum StationSharing {
    static func text(for station: Station) -> String {
        let url = StationProfile.all[station.id]?.website ?? station.streamURL
        return "\(station.name) · \(station.frequencyLabel)\n\(station.city), \(station.region.country)\n\(url.absoluteString)"
    }
}
