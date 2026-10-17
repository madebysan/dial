import Foundation

enum RadioBand: String, CaseIterable, Identifiable, Codable {
    case fm = "FM", am = "AM", online = "Live"
    // Preserve catalogue and saved band keys while using a clearer interface label.
    var displayName: String { self == .online ? "Other stations" : rawValue }
    var id: String { rawValue }
    var range: ClosedRange<Double> { self == .am ? 520...1710 : 76...108 }
    var pointsPerUnit: Double { self == .am ? 0.82 : 82 }
}

/// Catalogue collections. Original raw values remain stable for saved selections.
/// A collection is separate from the station's local tuning scope.
enum RadioRegion: String, CaseIterable, Identifiable, Codable {
    case newYork, montevideo, argentina, spain, brazil, mexico, colombia, chile
    case unitedKingdom, france, italy, japan
    var id: String { rawValue }
    var name: String { country }
    var country: String {
        switch self {
        case .newYork: "United States"
        case .montevideo: "Uruguay"
        case .argentina: "Argentina"
        case .spain: "Spain"
        case .brazil: "Brazil"
        case .mexico: "Mexico"
        case .colombia: "Colombia"
        case .chile: "Chile"
        case .unitedKingdom: "United Kingdom"
        case .france: "France"
        case .italy: "Italy"
        case .japan: "Japan"
        }
    }
    init?(countryCode: String) {
        switch countryCode.uppercased() {
        case "US": self = .newYork
        case "UY": self = .montevideo
        case "AR": self = .argentina
        case "ES": self = .spain
        case "BR": self = .brazil
        case "MX": self = .mexico
        case "CO": self = .colombia
        case "CL": self = .chile
        case "GB": self = .unitedKingdom
        case "FR": self = .france
        case "IT": self = .italy
        case "JP": self = .japan
        default: return nil
        }
    }
    var defaultStationID: String { self == .newYork ? "wnyc" : self == .montevideo ? "futura" : "" }
}

struct Station: Identifiable, Hashable, Decodable {
    let id: String
    let name: String
    let frequency: Double?
    let detail: String
    let city: String
    let region: RadioRegion
    let streamURL: URL
    let band: RadioBand
    /// Optional metro grouping for neighboring cities that share one local dial.
    var tuningArea: String? = nil

    var tuningFrequency: Double { frequency ?? 0 }
    var hasDial: Bool { frequency != nil && band != .online }
    var dialScope: String {
        if let tuningArea { return tuningArea }
        // Both catalogue batches describe the same Los Angeles dial.
        if region == .newYork && city == "Los Angeles" { return "losAngeles" }
        return "\(region.rawValue)-\(city)"
    }
    var tuningLocationName: String {
        switch tuningArea {
        case "newYork": "New York metro"
        case "losAngeles": "Los Angeles"
        default: city
        }
    }
    var frequencyText: String {
        guard let frequency else { return "Live" }
        return String(format: band == .fm ? "%.1f" : "%.0f", frequency)
    }
    var frequencyLabel: String { hasDial ? "\(frequencyText) \(band.rawValue)" : "Live stream" }

    static let sample: [Station] = {
        guard let url = Bundle.main.url(forResource: "stations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let stations = try? JSONDecoder().decode([Station].self, from: data), !stations.isEmpty else {
            preconditionFailure("The bundled station catalogue could not be loaded")
        }
        return stations
    }()

    static func nearest(to frequency: Double, in stations: [Station] = sample) -> Station? {
        stations.filter(\.hasDial).min { abs($0.tuningFrequency - frequency) < abs($1.tuningFrequency - frequency) }
    }
}

struct TuningLocation: Identifiable {
    let id: String
    let name: String
    let stations: [Station]
    let isOnline: Bool

    var summary: String {
        "\(stations.count) \(stations.count == 1 ? "station" : "stations")"
    }
}
