import SwiftUI

struct PrayerRowView: View {
    let entry: PrayerTimeEntry
    let isNext: Bool

    var body: some View {
        HStack {
            Image(systemName: entry.kind.symbolName)
                .imageScale(.large)
            Text(entry.kind.displayName)
                .font(.title3)
                .bold(isNext)
            Spacer()
            Text(PrayerTimeFormatter.shared.string(from: entry.date))
                .font(isNext ? .title2 : .title3)
                .foregroundStyle(isNext ? .primary : .secondary)
        }
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
