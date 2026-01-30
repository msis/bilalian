import Foundation

/// Schedules Athan playback while the app is active.
@MainActor
final class AthanScheduler: ObservableObject {
    private var pendingTask: Task<Void, Never>?
    private let onFire: (PrayerTimeEntry, TimeZone) -> Void
    /// Allow slightly late firing to avoid missing near-now prayers.
    private let immediateTolerance: TimeInterval = 45
    /// Bound late catch-up to avoid firing stale alerts.
    private let catchUpWindow: TimeInterval = 120

    init(onFire: @escaping (PrayerTimeEntry, TimeZone) -> Void) {
        self.onFire = onFire
    }

    /// Cancels any scheduled Athan playback.
    func cancel() {
        pendingTask?.cancel()
        pendingTask = nil
    }

    /// Schedules Athan playback at the next eligible prayer time.
    func scheduleNextPrayer(from schedule: PrayerSchedule, nextDayEntries: [PrayerTimeEntry], preferences: NotificationPreferences, leadTime: NotificationLeadTime, now: Date = Date()) {
        cancel()

        guard let nextEntry = nextEligibleEntry(from: schedule.entries, nextDayEntries: nextDayEntries, preferences: preferences, leadTime: leadTime, now: now) else {
            return
        }

        let fireDate = nextEntry.date.addingTimeInterval(TimeInterval(-leadTime.minutesOffset * 60))
        let delay = max(0, fireDate.timeIntervalSince(now))

        #if DEBUG
        let formatter = ISO8601DateFormatter()
        print("[AthanScheduler] now=\(formatter.string(from: now))")
        print("[AthanScheduler] next=\(nextEntry.kind) at \(formatter.string(from: nextEntry.date))")
        print("[AthanScheduler] fire=\(formatter.string(from: fireDate)) delay=\(delay)s")
        #endif

        pendingTask = Task { [weak self] in
            if delay > 0 {
                let clock = ContinuousClock()
                let deadline = clock.now.advanced(by: .seconds(delay))
                do {
                    try await Task.sleep(until: deadline, clock: clock)
                } catch {
                    return
                }
            }
            guard !Task.isCancelled else { return }
            #if DEBUG
            print("[AthanScheduler] Firing Athan now")
            #endif
            self?.onFire(nextEntry, schedule.timeZone)
        }
    }

    private func nextEligibleEntry(from entries: [PrayerTimeEntry], nextDayEntries: [PrayerTimeEntry], preferences: NotificationPreferences, leadTime: NotificationLeadTime, now: Date) -> PrayerTimeEntry? {
        let enabledEntries = (entries + nextDayEntries)
            .filter { $0.kind.isNotifiable && preferences.isEnabled(for: $0.kind) }
            .sorted { $0.date < $1.date }

        return enabledEntries.first { entry in
            let fireDate = entry.date.addingTimeInterval(TimeInterval(-leadTime.minutesOffset * 60))
            let windowStart = fireDate.addingTimeInterval(-immediateTolerance)
            let windowEnd = fireDate.addingTimeInterval(catchUpWindow)
            return now >= windowStart && now <= windowEnd
        } ?? enabledEntries.first { entry in
            let fireDate = entry.date.addingTimeInterval(TimeInterval(-leadTime.minutesOffset * 60))
            return fireDate >= now.addingTimeInterval(-immediateTolerance)
        }
    }
}
