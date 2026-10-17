import SwiftUI

struct StationAlarmsView: View {
    let radio: RadioPlayer
    @State private var showsAdd = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if !radio.alarms.isSupported {
                Text("Station alarms require iOS 26.1 or later.")
                    .foregroundStyle(Palette.secondary).listRowBackground(Palette.paper)
            } else {
                if let message = radio.alarms.statusMessage {
                    Text(message).foregroundStyle(Palette.secondary).listRowBackground(Palette.paper)
                }
                Section {
                    ForEach(radio.alarms.records) { alarm in
                        Toggle(isOn: Binding(get: { alarm.isEnabled }, set: { enabled in
                            Task {
                                do { try await radio.alarms.setEnabled(enabled, id: alarm.id) }
                                catch { errorMessage = error.localizedDescription }
                            }
                        })) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(alarm.timeText).font(.title2.monospacedDigit())
                                Text(alarm.stationName).font(.subheadline)
                                Text(alarm.repetition.rawValue).font(.caption).foregroundStyle(Palette.secondary)
                            }
                        }
                        .disabled(radio.alarms.isWorking)
                        .accessibilityIdentifier("station-alarm-\(alarm.id)")
                    }
                    .onDelete { offsets in
                        let ids = offsets.map { radio.alarms.records[$0].id }
                        do { for id in ids { try radio.alarms.remove(id) } }
                        catch { errorMessage = error.localizedDescription }
                    }
                    if radio.alarms.records.isEmpty {
                        Text("No station alarms").foregroundStyle(Palette.secondary)
                    }
                    Button("Add alarm", systemImage: "plus") { showsAdd = true }
                        .accessibilityIdentifier("add-station-alarm")
                } footer: {
                    Text("The iPhone alarm rings even when Dial is closed. Tap Play station on the alarm to open Dial and start the stream. An internet connection is required for radio playback.")
                }
                .listRowBackground(Palette.surface)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Palette.paper)
        .navigationTitle("Station alarms")
        .onAppear { radio.alarms.refresh() }
        .sheet(isPresented: $showsAdd) { AddStationAlarmView(radio: radio) }
        .alert("Alarm couldn’t be updated", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
}

private struct AddStationAlarmView: View {
    let radio: RadioPlayer
    @State private var stationID: String
    @State private var time = Date.now.addingTimeInterval(3600)
    @State private var repetition: StationAlarm.Repetition = .once
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    init(radio: RadioPlayer) {
        self.radio = radio
        _stationID = State(initialValue: radio.selected.id)
    }
    private var station: Station? { radio.library.stations.first { $0.id == stationID } }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    Picker("Repeat", selection: $repetition) {
                        ForEach(StationAlarm.Repetition.allCases) { Text($0.rawValue).tag($0) }
                    }
                    NavigationLink {
                        AlarmStationPicker(stations: radio.library.stations, selection: $stationID)
                    } label: { LabeledContent("Station", value: station?.name ?? "Choose station") }
                }
                .listRowBackground(Palette.surface)
                Section {
                    Text("Dial will ask for alarm permission when you save your first alarm. The alarm uses the iPhone’s current time zone.")
                        .font(.footnote).foregroundStyle(Palette.secondary)
                }
                .listRowBackground(Palette.paper)
            }
            .scrollContentBackground(.hidden)
            .background(Palette.paper)
            .navigationTitle("New alarm")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.disabled(radio.alarms.isWorking) }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let station else { return }
                        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                        Task {
                            do {
                                try await radio.alarms.add(station: station, hour: components.hour ?? 0,
                                                          minute: components.minute ?? 0, repetition: repetition)
                                dismiss()
                            } catch { errorMessage = error.localizedDescription }
                        }
                    }
                    .disabled(radio.alarms.isWorking || station == nil)
                    .accessibilityIdentifier("save-station-alarm")
                }
            }
        }
        .tint(Palette.accent)
        .interactiveDismissDisabled(radio.alarms.isWorking)
        .alert("Alarm couldn’t be saved", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
}

private struct AlarmStationPicker: View {
    let stations: [Station]
    @Binding var selection: String
    @State private var search = ""
    @Environment(\.dismiss) private var dismiss
    private var filtered: [Station] {
        stations.filter { search.isEmpty || "\($0.name) \($0.city) \($0.region.country)".localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        List(filtered) { station in
            Button {
                selection = station.id
                dismiss()
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(station.name)
                        Text("\(station.city), \(station.region.country)").font(.caption).foregroundStyle(Palette.secondary)
                    }
                    Spacer()
                    if selection == station.id { Image(systemName: "checkmark") }
                }
                .foregroundStyle(Palette.ink)
            }
            .listRowBackground(Palette.surface)
        }
        .searchable(text: $search, prompt: "Station or city")
        .scrollContentBackground(.hidden)
        .background(Palette.paper)
        .navigationTitle("Choose station")
    }
}
