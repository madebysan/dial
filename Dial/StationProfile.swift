import Foundation

struct StationProfile: Decodable {
    struct Source: Decodable, Identifiable {
        let label: String
        let url: URL
        var id: String { url.absoluteString }
    }

    let stationID: String
    let summary: String
    let locationLabel: String?
    let genres: [String]
    let languages: [String]
    let website: URL?
    let artworkURL: URL?
    let artworkAsset: String?
    let artworkBackground: String?
    let artworkStatus: String
    let identityStatus: String
    let codec: String
    let bitrateKbps: Int?
    let titlesObserved: Bool
    let checkedOn: String
    let notes: [String]
    let sources: [Source]

    static let all: [String: StationProfile] = {
        guard let url = Bundle.main.url(forResource: "station-profiles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let profiles = try? JSONDecoder().decode([StationProfile].self, from: data) else {
            assertionFailure("The bundled station profiles could not be loaded")
            return [:]
        }
        return Dictionary(profiles.map { ($0.stationID, $0) }, uniquingKeysWith: { first, _ in first })
    }()
}
