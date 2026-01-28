import Foundation
import UserNotifications

final class NotificationService {
    func requestAuthorization() async {
        #if os(tvOS)
        return
        #else
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
        #endif
    }

    func scheduleNotifications(for schedule: PrayerSchedule, preferences: NotificationPreferences) async {
        #if os(tvOS)
        return
        #else
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for entry in schedule.entries where entry.kind.isNotifiable {
            guard preferences.isEnabled(for: entry.kind) else { continue }
            let content = UNMutableNotificationContent()
            content.title = "Prayer Time"
            content.body = "It is time for \(entry.kind.displayName)."
            content.sound = .default

            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: entry.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: "prayer-\(entry.kind.rawValue)-\(entry.date.timeIntervalSince1970)", content: content, trigger: trigger)
            try? await center.add(request)
        }
        #endif
    }
}
