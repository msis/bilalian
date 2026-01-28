import Foundation

enum PrayerKind: String, CaseIterable, Identifiable, Codable {
    case fajr
    case sunrise
    case dhuhr
    case asr
    case maghrib
    case isha

    var id: String { rawValue }

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

    var isNotifiable: Bool {
        self != .sunrise
    }
}

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
