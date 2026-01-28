import Foundation

/// Supported prayer time categories shown in the UI.
enum PrayerKind: String, CaseIterable, Identifiable, Codable {
    case fajr
    case sunrise
    case dhuhr
    case asr
    case maghrib
    case isha

    var id: String { rawValue }

    /// User-facing name for display.
    var displayName: String {
        switch self {
        case .fajr: return "Fajr"
        case .sunrise: return "Sunrise"
        case .dhuhr: return "Dhuhr"
        case .asr: return "Asr"
        case .maghrib: return "Maghrib"
        case .isha: return "Isha"
        }
    }

    /// Whether the prayer can be scheduled as a notification.
    var isNotifiable: Bool {
        self != .sunrise
    }

    /// SF Symbol used to represent the prayer in the list.
    var symbolName: String {
        switch self {
        case .fajr:
            return "light.max"
        case .sunrise:
            return "sunrise"
        case .dhuhr:
            return "sun.max"
        case .asr:
            return "sun.min"
        case .maghrib:
            return "sunset"
        case .isha:
            return "moon.stars"
        }
    }
}

/// A single prayer time for the current day.
struct PrayerTimeEntry: Identifiable, Hashable {
    let id = UUID()
    let kind: PrayerKind
    let date: Date

    static func == (lhs: PrayerTimeEntry, rhs: PrayerTimeEntry) -> Bool {
        lhs.kind == rhs.kind && lhs.date == rhs.date
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
        hasher.combine(date)
    }
}
