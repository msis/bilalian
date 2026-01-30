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
    var timeZoneIdentifier: String?

    /// Convenience Core Location coordinate for MapKit/Adhan.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Returns the resolved time zone for this location.
    var timeZone: TimeZone {
        guard let identifier = timeZoneIdentifier,
              !identifier.isEmpty,
              let timeZone = TimeZone(identifier: identifier) else {
            return .current
        }
        return timeZone
    }

    /// Returns true when the time zone identifier is resolved and valid.
    var hasResolvedTimeZone: Bool {
        guard let identifier = timeZoneIdentifier,
              !identifier.isEmpty else {
            return false
        }
        return TimeZone(identifier: identifier) != nil
    }

    /// Returns true when coordinates are within valid bounds.
    var hasValidCoordinates: Bool {
        (-90...90).contains(latitude) && (-180...180).contains(longitude)
    }
}

/// Persisted settings for the app.
struct AppSettings: Codable, Equatable {
    var locationSelection: LocationSelection?
    var calculationMethod: CalculationMethodOption = .muslimWorldLeague
    var notificationPrefs: NotificationPreferences = NotificationPreferences()
    var notificationLeadTime: NotificationLeadTime = .atTime
    var hasCompletedOnboarding: Bool = false
}

/// Lead time options for prayer alerts.
enum NotificationLeadTime: String, CaseIterable, Identifiable, Codable {
    case atTime
    case minutes5
    case minutes10
    case minutes15
    case minutes30
    case hour1

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .atTime: return "At time"
        case .minutes5: return "5 minutes before"
        case .minutes10: return "10 minutes before"
        case .minutes15: return "15 minutes before"
        case .minutes30: return "30 minutes before"
        case .hour1: return "1 hour before"
        }
    }

    var minutesOffset: Int {
        switch self {
        case .atTime: return 0
        case .minutes5: return 5
        case .minutes10: return 10
        case .minutes15: return 15
        case .minutes30: return 30
        case .hour1: return 60
        }
    }
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
