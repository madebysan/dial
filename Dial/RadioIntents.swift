import AppIntents
import Observation

struct PlaybackCommand: Equatable {
    enum Action: Equatable {
        case station(String), resume, pause
    }
    let id = UUID()
    let action: Action
}

@MainActor @Observable
final class PlaybackCommands {
    static let shared = PlaybackCommands()
    private(set) var pending: PlaybackCommand?

    func request(_ action: PlaybackCommand.Action) { pending = PlaybackCommand(action: action) }
    func clear(_ id: UUID) { if pending?.id == id { pending = nil } }

    nonisolated static func action(for url: URL) -> PlaybackCommand.Action? {
        guard url.scheme?.lowercased() == "dialradio" else { return nil }
        switch url.host {
        case "station":
            let parts = url.pathComponents.filter { $0 != "/" }
            guard parts.count == 1, !parts[0].isEmpty else { return nil }
            return .station(parts[0])
        case "play": return .resume
        case "pause": return .pause
        default: return nil
        }
    }
}

struct RadioStationEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Radio station"
    static let defaultQuery = RadioStationQuery()
    let id: String
    let name: String
    let location: String

    init(_ station: Station) {
        id = station.id
        name = station.name
        location = "\(station.city), \(station.region.country)"
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(location)")
    }
}

struct RadioStationQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [RadioStationEntity] {
        Station.sample.filter { identifiers.contains($0.id) }.map(RadioStationEntity.init)
    }

    func suggestedEntities() async throws -> [RadioStationEntity] {
        let favorites = Set(UserDefaults.standard.stringArray(forKey: "favorites") ?? [])
        let stations = Station.sample.filter { favorites.contains($0.id) }
        return (stations.isEmpty ? Array(Station.sample.prefix(12)) : stations).map(RadioStationEntity.init)
    }

    func entities(matching string: String) async throws -> [RadioStationEntity] {
        Station.sample.filter {
            "\($0.name) \($0.city) \($0.region.country)".localizedCaseInsensitiveContains(string)
        }.map(RadioStationEntity.init)
    }
}

enum RadioIntentError: LocalizedError {
    case missingStation
    var errorDescription: String? { "This station is no longer in Dial’s catalogue." }
}

struct PlayStationIntent: AppIntent {
    static let title: LocalizedStringResource = "Play station"
    static let description = IntentDescription("Open Dial and play a radio station. Favorites appear first in the station suggestions.")
    static let openAppWhenRun = true
    @Parameter(title: "Station") var station: RadioStationEntity
    static var parameterSummary: some ParameterSummary { Summary("Play \(\.$station)") }

    func perform() async throws -> some IntentResult {
        guard Station.sample.contains(where: { $0.id == station.id }) else { throw RadioIntentError.missingStation }
        await PlaybackCommands.shared.request(.station(station.id))
        return .result()
    }
}

struct ResumeRadioIntent: AppIntent {
    static let title: LocalizedStringResource = "Play Dial"
    static let description = IntentDescription("Open Dial and play the last station.")
    static let openAppWhenRun = true
    func perform() async throws -> some IntentResult {
        await PlaybackCommands.shared.request(.resume)
        return .result()
    }
}

struct PauseRadioIntent: AppIntent {
    static let title: LocalizedStringResource = "Pause Dial"
    static let openAppWhenRun = true
    func perform() async throws -> some IntentResult {
        await PlaybackCommands.shared.request(.pause)
        return .result()
    }
}

struct DialShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: ResumeRadioIntent(), phrases: ["Play \(.applicationName)", "Listen to \(.applicationName)"],
                    shortTitle: "Play Dial", systemImageName: "play.fill")
        AppShortcut(intent: PlayStationIntent(), phrases: ["Play \(\.$station) in \(.applicationName)"],
                    shortTitle: "Play station", systemImageName: "radio")
        AppShortcut(intent: PauseRadioIntent(), phrases: ["Pause \(.applicationName)"],
                    shortTitle: "Pause Dial", systemImageName: "pause.fill")
    }
}
