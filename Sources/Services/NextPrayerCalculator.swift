import Foundation

/// Picks the next prayer from today's or next day's entries.
struct NextPrayerCalculator {
    /// Returns the next upcoming entry, falling back to the next day's list.
    static func nextPrayer(
        from entries: [PrayerTimeEntry],
        at date: Date = Date(),
        nextDayEntries: [PrayerTimeEntry] = []
    ) -> PrayerTimeEntry? {
        if let upcoming = entries.first(where: { $0.date > date }) {
            return upcoming
        }
        return nextDayEntries.first
    }
}
