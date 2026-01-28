import Foundation
import CoreLocation

/// Supported calculation methods from the Adhan library.
enum CalculationMethodOption: String, CaseIterable, Identifiable, Codable {
    case muslimWorldLeague
    case egyptian
    case ummAlQura
    case isna
    case dubai
    case moonsightingCommittee

    var id: String { rawValue }

    /// Human-readable name used in settings.
    var displayName: String {
        switch self {
        case .muslimWorldLeague: return "Muslim World League"
        case .egyptian: return "Egyptian"
        case .ummAlQura: return "Umm al-Qura"
        case .isna: return "ISNA"
        case .dubai: return "Dubai"
        case .moonsightingCommittee: return "Moonsighting Committee"
        }
    }
}

/// Saved location data for prayer time calculations.
struct LocationSelection: Codable, Equatable {
    var name: String
    var latitude: Double
    var longitude: Double
    var isCurrentLocation: Bool

    /// Convenience Core Location coordinate for MapKit/Adhan.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// Persisted settings for the app.
struct AppSettings: Codable, Equatable {
    var locationSelection: LocationSelection?
    var calculationMethod: CalculationMethodOption = .muslimWorldLeague
    var notificationPrefs: NotificationPreferences = NotificationPreferences()
    var hasCompletedOnboarding: Bool = false
}

/// Per-prayer notification toggles.
struct NotificationPreferences: Codable, Equatable {
    var fajr: Bool = true
    var dhuhr: Bool = true
    var asr: Bool = true
    var maghrib: Bool = true
    var isha: Bool = true

    /// Returns true if a prayer is enabled for notifications.
    func isEnabled(for kind: PrayerKind) -> Bool {
        switch kind {
        case .fajr: return fajr
        case .dhuhr: return dhuhr
        case .asr: return asr
        case .maghrib: return maghrib
        case .isha: return isha
        case .sunrise: return false
        }
    }

    /// Updates a prayer's notification toggle.
    mutating func setEnabled(_ enabled: Bool, for kind: PrayerKind) {
        switch kind {
        case .fajr: fajr = enabled
        case .dhuhr: dhuhr = enabled
        case .asr: asr = enabled
        case .maghrib: maghrib = enabled
        case .isha: isha = enabled
        case .sunrise: break
        }
    }
}
