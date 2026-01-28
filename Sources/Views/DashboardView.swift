import SwiftUI

/// Main screen showing daily prayer times and countdown.
struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var timer = CountdownTimerService()

    var body: some View {
        NavigationStack {
            ZStack {
                TimeOfDayBackground(date: timer.now)
                let nextPrayer = nextPrayerEntry
                VStack(alignment: .leading, spacing: 24) {
                    header(nextPrayer: nextPrayer)
                    scheduleList
                    Spacer()
                    DateFooterView(
                        display: DateService.shared.displayStrings(for: timer.now),
                        currentTime: DateService.shared.timeString(for: timer.now)
                    )
                        .frame(maxWidth: .infinity)
                }
                .padding(40)
            }
            .navigationTitle("Prayer Times")
            .toolbar {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            .onAppear {
                timer.start()
                appState.refreshSchedule()
            }
            .onDisappear {
                timer.stop()
            }
        }
    }

    /// Header showing location and next prayer countdown.
    private func header(nextPrayer: PrayerTimeEntry?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appState.settings.locationSelection?.name ?? "")
                .font(.caption)
            if let nextPrayer = nextPrayer {
                Text("Next: \(nextPrayer.kind.displayName) in \(countdownString(to: nextPrayer.date))")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            } else {
                Text("No upcoming prayers")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Prayer list for the day.
    private var scheduleList: some View {
        VStack(spacing: 12) {
            ForEach(appState.schedule?.entries ?? []) { entry in
                let isNext = entry.id == nextPrayerEntry?.id
                PrayerRowView(entry: entry, isNext: isNext)
            }
        }
        .padding(.top, 8)
    }

    /// Computes the next upcoming prayer, falling back to tomorrow.
    private var nextPrayerEntry: PrayerTimeEntry? {
        guard let location = appState.settings.locationSelection else {
            return nil
        }
        let todayEntries = appState.schedule?.entries ?? []
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: timer.now) ?? timer.now
        let nextDayEntries = appState.prayerEntries(for: location, on: tomorrow)
        return NextPrayerCalculator.nextPrayer(
            from: todayEntries,
            at: timer.now,
            nextDayEntries: nextDayEntries
        )
    }

    /// Formats a countdown interval as HH:mm:ss.
    private func countdownString(to date: Date) -> String {
        let interval = max(0, Int(date.timeIntervalSince(timer.now)))
        let hours = interval / 3600
        let minutes = (interval % 3600) / 60
        let seconds = interval % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environmentObject(AppState.previewValue)
    }
}
