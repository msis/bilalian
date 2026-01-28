import Foundation
import Adhan

struct PrayerSchedule {
    let entries: [PrayerTimeEntry]
}

final class PrayerTimeService {
    func schedule(for location: LocationSelection, method: CalculationMethodOption, date: Date = Date()) -> PrayerSchedule? {
        let entries = entries(for: location, method: method, date: date)
        return PrayerSchedule(entries: entries)
    }

    func entries(for location: LocationSelection, method: CalculationMethodOption, date: Date) -> [PrayerTimeEntry] {
        let calendar = Calendar(identifier: .gregorian)
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
