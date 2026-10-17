#if canImport(AlarmKit)
import AlarmKit
#endif
import AppIntents
import Observation
import SwiftUI

struct StationAlarm: Codable, Identifiable, Equatable {
    enum Repetition: String, Codable, CaseIterable, Identifiable {
        case once = "Once", daily = "Every day", weekdays = "Weekdays"
        var id: String { rawValue }
    }
    let id: UUID
    let stationID: String
    let stationName: String
    let hour: Int
    let minute: Int
    let repetition: Repetition
    var isEnabled: Bool

    var timeText: String {
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }
}

@MainActor
protocol AlarmScheduling {
    var supported: Bool { get }
    var authorized: Bool { get }
    func requestAuthorization() async throws -> Bool
    func schedule(_ alarm: StationAlarm) async throws
    func cancel(_ id: UUID) throws
    func activeIDs() throws -> Set<UUID>
}

#if canImport(AlarmKit)
@MainActor
final class SystemAlarmScheduler: AlarmScheduling {
    var supported: Bool { if #available(iOS 26.1, *) { true } else { false } }
    var authorized: Bool {
        if #available(iOS 26.1, *) { AlarmManager.shared.authorizationState == .authorized } else { false }
    }

    func requestAuthorization() async throws -> Bool {
        guard #available(iOS 26.1, *) else { throw StationAlarms.AlarmError.unsupported }
        return try await AlarmManager.shared.requestAuthorization() == .authorized
    }

    func schedule(_ alarm: StationAlarm) async throws {
        guard #available(iOS 26.1, *) else { throw StationAlarms.AlarmError.unsupported }
        let days: [Locale.Weekday]
        switch alarm.repetition {
        case .once: days = []
        case .daily: days = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        case .weekdays: days = [.monday, .tuesday, .wednesday, .thursday, .friday]
        }
        let schedule = Alarm.Schedule.relative(.init(time: .init(hour: alarm.hour, minute: alarm.minute),
                                                     repeats: days.isEmpty ? .never : .weekly(days)))
        let presentation = AlarmPresentation(alert: .init(title: "Time for \(alarm.stationName)",
            secondaryButton: AlarmButton(text: "Play station", textColor: .black, systemImageName: "play.fill"),
            secondaryButtonBehavior: .custom))
        let attributes = AlarmAttributes(presentation: presentation,
            metadata: RadioAlarmMetadata(stationID: alarm.stationID), tintColor: .white)
        let configuration = AlarmManager.AlarmConfiguration.alarm(schedule: schedule, attributes: attributes,
            secondaryIntent: PlayAlarmStationIntent(alarmID: alarm.id, stationID: alarm.stationID))
        _ = try await AlarmManager.shared.schedule(id: alarm.id, configuration: configuration)
    }

    func cancel(_ id: UUID) throws {
        guard #available(iOS 26.1, *) else { return }
        if try activeIDs().contains(id) { try AlarmManager.shared.cancel(id: id) }
    }

    func activeIDs() throws -> Set<UUID> {
        guard #available(iOS 26.1, *) else { return [] }
        return Set(try AlarmManager.shared.alarms.map(\.id))
    }
}

@available(iOS 26.1, *)
struct RadioAlarmMetadata: AlarmMetadata { let stationID: String }

@available(iOS 26.1, *)
struct PlayAlarmStationIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Play alarm station"
    static let openAppWhenRun = true
    static let isDiscoverable = false
    @Parameter(title: "Alarm") var alarmID: String
    @Parameter(title: "Station") var stationID: String

    init() {}
    init(alarmID: UUID, stationID: String) {
        self.alarmID = alarmID.uuidString
        self.stationID = stationID
    }

    func perform() async throws -> some IntentResult {
        if let id = UUID(uuidString: alarmID) {
            do { try AlarmManager.shared.stop(id: id) }
            catch {
                // A second action may arrive after the system has already stopped it.
                if (try? AlarmManager.shared.alarms.contains { $0.id == id && $0.state == .alerting }) == true { throw error }
            }
        }
        guard Station.sample.contains(where: { $0.id == stationID }) else { throw RadioIntentError.missingStation }
        await PlaybackCommands.shared.request(.station(stationID))
        return .result()
    }
}
#else
/// AlarmKit is iPhone-only, so the Mac build keeps alarm records readable but cannot ring them.
@MainActor
final class SystemAlarmScheduler: AlarmScheduling {
    var supported: Bool { false }
    var authorized: Bool { false }
    func requestAuthorization() async throws -> Bool { throw StationAlarms.AlarmError.unsupported }
    func schedule(_ alarm: StationAlarm) async throws { throw StationAlarms.AlarmError.unsupported }
    func cancel(_ id: UUID) throws {}
    func activeIDs() throws -> Set<UUID> { [] }
}
#endif

@MainActor @Observable
final class StationAlarms {
    private(set) var records: [StationAlarm] = []
    private(set) var isWorking = false
    private(set) var statusMessage: String?
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let scheduler: any AlarmScheduling
    @ObservationIgnored private var unreadable = false
    var isSupported: Bool { scheduler.supported }

    enum AlarmError: LocalizedError {
        case unsupported, permissionDenied, invalidTime, unreadable, busy
        var errorDescription: String? {
            switch self {
            case .busy: "An alarm is being updated. Try again in a moment."
            case .unsupported: "Station alarms require iOS 26.1 or later."
            case .permissionDenied: "Allow alarms for Dial in iPhone Settings, then try again."
            case .invalidTime: "Choose a valid alarm time."
            case .unreadable: "Saved alarms could not be read and have been kept unchanged."
            }
        }
    }

    init(defaults: UserDefaults = .standard, scheduler: (any AlarmScheduling)? = nil) {
        self.defaults = defaults
        self.scheduler = scheduler ?? SystemAlarmScheduler()
        if let data = defaults.data(forKey: "stationAlarms") {
            do { records = try JSONDecoder().decode([StationAlarm].self, from: data) }
            catch { unreadable = true; statusMessage = AlarmError.unreadable.localizedDescription }
        }
    }

    @discardableResult
    func add(station: Station, hour: Int, minute: Int, repetition: StationAlarm.Repetition) async throws -> UUID {
        guard !unreadable else { throw AlarmError.unreadable }
        guard !isWorking else { throw AlarmError.busy }
        isWorking = true
        defer { isWorking = false }
        guard (0..<24).contains(hour), (0..<60).contains(minute) else { throw AlarmError.invalidTime }
        guard scheduler.supported else { throw AlarmError.unsupported }
        let record = StationAlarm(id: UUID(), stationID: station.id, stationName: station.name,
                                  hour: hour, minute: minute, repetition: repetition, isEnabled: true)
        let updated = records + [record]
        let data = try JSONEncoder().encode(updated)
        guard try await scheduler.requestAuthorization() else { throw AlarmError.permissionDenied }
        try await scheduler.schedule(record)
        defaults.set(data, forKey: "stationAlarms")
        records = updated
        statusMessage = nil
        return record.id
    }

    func setEnabled(_ enabled: Bool, id: UUID) async throws {
        guard !unreadable else { throw AlarmError.unreadable }
        guard !isWorking else { throw AlarmError.busy }
        isWorking = true
        defer { isWorking = false }
        guard let index = records.firstIndex(where: { $0.id == id }) else { return }
        var updated = records
        updated[index].isEnabled = enabled
        let data = try JSONEncoder().encode(updated)
        if enabled {
            guard try await scheduler.requestAuthorization() else { throw AlarmError.permissionDenied }
            try await scheduler.schedule(updated[index])
        } else { try scheduler.cancel(id) }
        defaults.set(data, forKey: "stationAlarms")
        records = updated
        statusMessage = nil
    }

    func remove(_ id: UUID) throws {
        guard !unreadable else { throw AlarmError.unreadable }
        guard !isWorking else { throw AlarmError.busy }
        isWorking = true
        defer { isWorking = false }
        let updated = records.filter { $0.id != id }
        let data = try JSONEncoder().encode(updated)
        try scheduler.cancel(id)
        defaults.set(data, forKey: "stationAlarms")
        records = updated
    }

    func refresh() {
        guard !unreadable, !isWorking, scheduler.supported else { return }
        guard scheduler.authorized else {
            statusMessage = records.isEmpty ? nil : "Alarm access is off. Allow it in iPhone Settings to use station alarms."
            return
        }
        do {
            let ids = try scheduler.activeIDs()
            var updated = records
            for index in updated.indices where updated[index].isEnabled && !ids.contains(updated[index].id) {
                updated[index].isEnabled = false
            }
            if updated != records {
                defaults.set(try JSONEncoder().encode(updated), forKey: "stationAlarms")
                records = updated
            }
            statusMessage = nil
        } catch { statusMessage = "Alarm status could not be checked. Try opening this screen again." }
    }
}
