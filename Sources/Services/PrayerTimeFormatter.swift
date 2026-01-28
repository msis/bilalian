import Foundation

/// Formats prayer time dates using the current locale.
struct PrayerTimeFormatter {
    static let shared = PrayerTimeFormatter()

    private let timeFormatter: DateFormatter

    private init() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.locale = .current
        timeFormatter = formatter
    }

    /// Formats a Date into a localized short time string.
    func string(from date: Date) -> String {
        timeFormatter.string(from: date)
    }
}
