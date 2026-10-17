import XCTest
@testable import Dial

@MainActor
private final class FakeAlarmScheduler: AlarmScheduling {
    var supported = true
    var authorized = true
    var failSchedule = false
    var failCancel = false
    var ids: Set<UUID> = []
    enum Failure: Error { case unavailable }
    func requestAuthorization() async throws -> Bool { authorized }
    func schedule(_ alarm: StationAlarm) async throws {
        if failSchedule { throw Failure.unavailable }
        ids.insert(alarm.id)
    }
    func cancel(_ id: UUID) throws {
        if failCancel { throw Failure.unavailable }
        ids.remove(id)
    }
    func activeIDs() throws -> Set<UUID> { ids }
}

@MainActor
final class AlarmTests: XCTestCase {
    func testCreateDisableEnableRemoveAndRestore() async throws {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let scheduler = FakeAlarmScheduler()
        let store = StationAlarms(defaults: defaults, scheduler: scheduler)
        let id = try await store.add(station: seedStations[0], hour: 7, minute: 30, repetition: .weekdays)
        XCTAssertTrue(scheduler.ids.contains(id))
        XCTAssertEqual(StationAlarms(defaults: defaults, scheduler: scheduler).records.first?.stationID, seedStations[0].id)
        try await store.setEnabled(false, id: id)
        XCTAssertFalse(scheduler.ids.contains(id))
        XCTAssertFalse(store.records[0].isEnabled)
        try await store.setEnabled(true, id: id)
        XCTAssertTrue(scheduler.ids.contains(id))
        try store.remove(id)
        XCTAssertTrue(store.records.isEmpty)
        XCTAssertTrue(scheduler.ids.isEmpty)
        XCTAssertTrue(StationAlarms(defaults: defaults, scheduler: scheduler).records.isEmpty)
    }

    func testDeniedOrFailedSchedulingDoesNotSaveAnAlarm() async {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let scheduler = FakeAlarmScheduler()
        let store = StationAlarms(defaults: defaults, scheduler: scheduler)
        scheduler.authorized = false
        do { _ = try await store.add(station: seedStations[0], hour: 7, minute: 0, repetition: .once); XCTFail("Must reject denied access") }
        catch { XCTAssertTrue(store.records.isEmpty) }
        scheduler.authorized = true
        scheduler.failSchedule = true
        do { _ = try await store.add(station: seedStations[0], hour: 7, minute: 0, repetition: .once); XCTFail("Must reject failed scheduling") }
        catch { XCTAssertTrue(store.records.isEmpty) }
        XCTAssertNil(defaults.data(forKey: "stationAlarms"))
        XCTAssertFalse(store.isWorking)
    }

    func testFailedCancellationKeepsTheExistingAlarm() async throws {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let scheduler = FakeAlarmScheduler()
        let store = StationAlarms(defaults: defaults, scheduler: scheduler)
        let id = try await store.add(station: seedStations[0], hour: 8, minute: 0, repetition: .daily)
        scheduler.failCancel = true
        do { try await store.setEnabled(false, id: id); XCTFail("Must expose failed cancellation") }
        catch { XCTAssertTrue(store.records[0].isEnabled) }
        XCTAssertTrue(scheduler.ids.contains(id))
        XCTAssertFalse(store.isWorking)
    }

    func testSystemRemovalDisablesTheLocalRecord() async throws {
        let name = "DialTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let scheduler = FakeAlarmScheduler()
        let store = StationAlarms(defaults: defaults, scheduler: scheduler)
        _ = try await store.add(station: seedStations[0], hour: 8, minute: 0, repetition: .once)
        scheduler.ids = []
        store.refresh()
        XCTAssertFalse(store.records[0].isEnabled)
        XCTAssertFalse(StationAlarms(defaults: defaults, scheduler: scheduler).records[0].isEnabled)
    }
}
