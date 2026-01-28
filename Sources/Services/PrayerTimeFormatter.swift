import Foundation

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

    func string(from date: Date) -> String {
        timeFormatter.string(from: date)
    }
}
