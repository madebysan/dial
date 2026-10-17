import CoreLocation
import MapKit
import Observation

@MainActor @Observable
final class CountryLocation: NSObject, CLLocationManagerDelegate {
    private(set) var isLoading = false
    private(set) var countryCode: String?
    private(set) var message: String?
    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private let legacyGeocoder = CLGeocoder()
    @ObservationIgnored private var timeout: Task<Void, Never>?
    @ObservationIgnored private var lookup: Task<Void, Never>?
    @ObservationIgnored private var requestID = UUID()
    @ObservationIgnored private let servicesEnabled: @Sendable () -> Bool
    @ObservationIgnored private let waitLimit: Duration

    static let servicesOffMessage = "Location Services is off. Turn it on in \(Platform.settingsApp) → Privacy & Security, or choose a country below."
    static let notFoundMessage = "Your country could not be found. Choose it manually."

    /// `servicesEnabled` and `waitLimit` are injectable for tests.
    init(servicesEnabled: @escaping @Sendable () -> Bool = { CLLocationManager.locationServicesEnabled() },
         waitLimit: Duration = .seconds(30)) {
        self.servicesEnabled = servicesEnabled
        self.waitLimit = waitLimit
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
    }

    func request() {
        cancel()
        message = nil
        countryCode = nil
        isLoading = true
        // Cover the whole request: with Location Services off, macOS never shows the prompt or calls back.
        startTimeout()
        let id = requestID
        let servicesEnabled = servicesEnabled
        Task { [weak self] in
            // Apple asks for this check off the main thread.
            let enabled = await Task.detached { servicesEnabled() }.value
            guard let self, self.isLoading, self.requestID == id else { return }
            guard enabled else { return self.fail(Self.servicesOffMessage) }
            switch self.manager.authorizationStatus {
            case .notDetermined: self.manager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse: self.locate()
            case .denied, .restricted: self.fail("Location access is off. Choose a country manually or enable access in \(Platform.settingsApp).")
            @unknown default: self.fail("Choose a country manually.")
            }
        }
    }

    func cancel() {
        requestID = UUID()
        timeout?.cancel()
        lookup?.cancel()
        legacyGeocoder.cancelGeocode()
        manager.stopUpdatingLocation()
        isLoading = false
    }

    private func locate() {
        guard isLoading else { return }
        manager.requestLocation()
        startTimeout()
    }

    private func startTimeout() {
        timeout?.cancel()
        let waitLimit = waitLimit
        timeout = Task { [weak self] in
            try? await Task.sleep(for: waitLimit)
            guard !Task.isCancelled else { return }
            self?.fail(Self.notFoundMessage)
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor [weak self] in
            guard let self, self.isLoading else { return }
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse: self.locate()
            case .denied, .restricted: self.fail("Location access is off. You can still choose a country manually.")
            default: break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor [weak self] in
            guard let self, self.isLoading, let location = locations.last else { return }
            self.resolve(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            guard let self, self.isLoading else { return }
            self.fail("Your location could not be read. Choose a country manually.")
        }
    }

    private func resolve(_ location: CLLocation) {
        manager.stopUpdatingLocation()
        let requestID = requestID
        lookup?.cancel()
        lookup = Task { [weak self] in
            guard let self else { return }
            do {
                let code: String?
                if #available(iOS 26.0, macOS 26.0, *) {
                    guard let request = MKReverseGeocodingRequest(location: location) else {
                        self.fail("Your country could not be found. Choose it manually.")
                        return
                    }
                    let items = try await request.mapItems
                    code = items.first?.addressRepresentations?.region?.identifier
                } else {
                    code = try await legacyGeocoder.reverseGeocodeLocation(location).first?.isoCountryCode
                }
                guard !Task.isCancelled, self.requestID == requestID else { return }
                self.timeout?.cancel()
                self.isLoading = false
                if let code {
                    self.countryCode = code
                } else {
                    self.message = "Your country could not be found. Choose it manually."
                }
            } catch {
                guard !Task.isCancelled, self.requestID == requestID else { return }
                self.fail("Your country could not be found. Choose it manually.")
            }
        }
    }

    private func fail(_ message: String) {
        cancel()
        self.message = message
    }
}
