import Foundation

/// Simple string bundle for the date footer.
struct DateDisplay {
    let gregorian: String
    let hijri: String
}

/// Centralized date formatting for Gregorian, Hijri, and time strings.
struct DateService {
    static let shared = DateService()

    private let gregorianFormatter: DateFormatter
    private let hijriFormatter: DateFormatter
    private let timeFormatter: DateFormatter

    private init() {
        let gregorian = DateFormatter()
        gregorian.calendar = Calendar(identifier: .gregorian)
        gregorian.dateStyle = .full
        gregorian.timeStyle = .none
        gregorianFormatter = gregorian

        let hijri = DateFormatter()
        hijri.calendar = Calendar(identifier: .islamicUmmAlQura)
        hijri.dateStyle = .full
        hijri.timeStyle = .none
        hijriFormatter = hijri

        let time = DateFormatter()
        time.dateStyle = .none
        time.timeStyle = .short
        timeFormatter = time
    }

    /// Returns formatted Gregorian and Hijri date strings.
    func displayStrings(for date: Date = Date()) -> DateDisplay {
        DateDisplay(
            gregorian: gregorianFormatter.string(from: date),
            hijri: hijriFormatter.string(from: date)
        )
    }

    /// Returns the localized current time string.
    func timeString(for date: Date = Date()) -> String {
        timeFormatter.string(from: date)
    }
}
