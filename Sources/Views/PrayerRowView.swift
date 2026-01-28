import SwiftUI

/// Single row showing prayer icon, name, and time.
struct PrayerRowView: View {
    let entry: PrayerTimeEntry
    let isNext: Bool

    var body: some View {
        HStack {
            Image(systemName: entry.kind.symbolName)
                .frame(width: 36, alignment: .center)
            Text(entry.kind.displayName)
            Spacer()
            Text(PrayerTimeFormatter.shared.string(from: entry.date))
        }
        .imageScale(isNext ? .large : .small)
        .bold(isNext)
        .font(isNext ? .title2 : .title3)
        .foregroundStyle(isNext ? .primary : .secondary)
        .padding(.vertical, 6)
    }
}

#Preview {
    List {
        PrayerRowView(
            entry: PrayerTimeEntry(
                kind: .fajr,
                date: Date()
            ),
            isNext: false
        )
        PrayerRowView(
            entry: PrayerTimeEntry(
                kind: .sunrise,
                date: Date().addingTimeInterval(1000)
            ),
            isNext: true
        )
        PrayerRowView(
            entry: PrayerTimeEntry(
                kind: .dhuhr,
                date: Date().addingTimeInterval(3600)
            ),
            isNext: false
        )
        PrayerRowView(
            entry: PrayerTimeEntry(
                kind: .asr,
                date: Date().addingTimeInterval(7200)
            ),
            isNext: false
        )
        PrayerRowView(
            entry: PrayerTimeEntry(
                kind: .maghrib,
                date: Date().addingTimeInterval(10800)
            ),
            isNext: false
        )
        PrayerRowView(
            entry: PrayerTimeEntry(
                kind: .isha,
                date: Date().addingTimeInterval(14400)
            ),
            isNext: false
        )
    }
}
