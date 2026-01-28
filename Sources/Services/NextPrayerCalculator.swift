import Foundation

struct NextPrayerCalculator {
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
