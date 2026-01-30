import Foundation
import Adhan

/// Grouped prayer times for a single day.
struct PrayerSchedule {
    let entries: [PrayerTimeEntry]
    let timeZone: TimeZone
}

/// Generates prayer times using the Adhan library.
final class PrayerTimeService {
    /// Returns the schedule wrapper for a given date.
    func schedule(for location: LocationSelection, method: CalculationMethodOption, date: Date = Date()) -> PrayerSchedule? {
        let calendar = calendarForSchedule(timeZone: location.timeZone)
        let entries = entries(for: location, method: method, date: date, calendar: calendar)
        return PrayerSchedule(entries: entries, timeZone: calendar.timeZone)
    }

    /// Returns the flat list of prayer entries for a date.
    func entries(for location: LocationSelection, method: CalculationMethodOption, date: Date) -> [PrayerTimeEntry] {
        let calendar = calendarForSchedule(timeZone: location.timeZone)
        return entries(for: location, method: method, date: date, calendar: calendar)
    }

    private func entries(for location: LocationSelection, method: CalculationMethodOption, date: Date, calendar: Calendar) -> [PrayerTimeEntry] {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let coordinates = Coordinates(latitude: location.latitude, longitude: location.longitude)
        var params = calculationParameters(for: method)
        params.highLatitudeRule = HighLatitudeRule.recommended(for: coordinates)

        guard let prayerTimes = PrayerTimes(coordinates: coordinates, date: components, calculationParameters: params) else {
            return []
        }

        return [
            PrayerTimeEntry(kind: .fajr, date: prayerTimes.fajr),
            PrayerTimeEntry(kind: .sunrise, date: prayerTimes.sunrise),
            PrayerTimeEntry(kind: .dhuhr, date: prayerTimes.dhuhr),
            PrayerTimeEntry(kind: .asr, date: prayerTimes.asr),
            PrayerTimeEntry(kind: .maghrib, date: prayerTimes.maghrib),
            PrayerTimeEntry(kind: .isha, date: prayerTimes.isha)
        ]
    }

    private func calendarForSchedule(timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    /// Maps the app's selection to Adhan calculation parameters.
    private func calculationParameters(for method: CalculationMethodOption) -> CalculationParameters {
        switch method {
        case .muslimWorldLeague:
            return CalculationMethod.muslimWorldLeague.params
        case .egyptian:
            return CalculationMethod.egyptian.params
        case .ummAlQura:
            return CalculationMethod.ummAlQura.params
        case .isna:
            return CalculationMethod.northAmerica.params
        case .dubai:
            return CalculationMethod.dubai.params
        case .moonsightingCommittee:
            return CalculationMethod.moonsightingCommittee.params
        }
    }
}
