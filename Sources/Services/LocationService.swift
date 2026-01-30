import CoreLocation
import Combine
#if os(tvOS)
import UIKit
#endif

/// Wraps CoreLocation for single-shot location updates.
final class LocationService: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastLocation: CLLocation?
    @Published var locationName: String?

    private let manager: CLLocationManager

    override init() {
        manager = CLLocationManager()
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// Requests When-In-Use authorization.
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    /// Requests a single location update.
    func requestLocation() {
        manager.requestLocation()
    }

    /// Resolves the time zone for a coordinate via reverse geocoding.
    func resolveTimeZone(for coordinate: CLLocationCoordinate2D) async -> TimeZone? {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.timeZone
        } catch {
            return nil
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        #if os(tvOS)
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
        #endif
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
}
