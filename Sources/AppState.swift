import Foundation
import Combine
import CoreLocation

/// Central app state and coordination for services + settings.
@MainActor
final class AppState: ObservableObject {
    @Published private(set) var settings: AppSettings
    @Published var schedule: PrayerSchedule?
    @Published var isLoading = false
    @Published var isAppActive = true
    @Published var shouldShowDashboard = false
    private var firedPrayerKeys = Set<String>()
    private var lastScheduleDayKey: String?

    let locationService = LocationService()
    let citySearchService = CitySearchService()

    private let settingsStore = SettingsStore()
    private let prayerService = PrayerTimeService()
    private let notificationService = NotificationService()
    private let athanPlayer = AthanPlayer()
    private lazy var athanScheduler = AthanScheduler { [weak self] entry, timeZone in
        self?.handleAthanFired(for: entry, in: timeZone)
    }
    private var dailyRefreshTask: Task<Void, Never>?
    private var notificationSchedulingTask: Task<Void, Never>?

    private var cancellables = Set<AnyCancellable>()

    init() {
        settings = settingsStore.load()
        bindLocationUpdates()
        #if !os(tvOS)
        Task {
            await notificationService.requestAuthorization()
        }
        #endif
        if settings.hasCompletedOnboarding, settings.locationSelection != nil {
            refreshSchedule()
        }
    }

    deinit {
        dailyRefreshTask?.cancel()
        notificationSchedulingTask?.cancel()
        cancellables.removeAll()
    }

    /// Marks onboarding as complete and refreshes the schedule.
    func completeOnboarding() {
        settings.hasCompletedOnboarding = true
        persistSettings()
        refreshSchedule()
    }

    /// Updates the saved location and recomputes the schedule.
    func updateLocation(_ selection: LocationSelection) {
        settings.locationSelection = selection
        persistSettings()
        refreshSchedule()
        resolveTimeZoneIfNeeded(for: selection)
    }

    /// Updates the calculation method and recomputes the schedule.
    func updateCalculationMethod(_ method: CalculationMethodOption) {
        settings.calculationMethod = method
        persistSettings()
        refreshSchedule()
    }

    /// Updates the toggle for a specific prayer.
    func updateNotificationPreference(_ kind: PrayerKind, enabled: Bool) {
        settings.notificationPrefs.setEnabled(enabled, for: kind)
        persistSettings()
        refreshSchedule()
    }

    /// Updates the lead time for prayer alerts.
    func updateNotificationLeadTime(_ leadTime: NotificationLeadTime) {
        settings.notificationLeadTime = leadTime
        persistSettings()
        refreshSchedule()
    }

    /// Updates the app active state and adjusts scheduling.
    func setAppActive(_ isActive: Bool) {
        isAppActive = isActive
        if !isActive {
            athanPlayer.stop()
        }
        refreshSchedule()
    }

    /// Triggers a location permission prompt.
    func requestLocation() {
        locationService.requestAuthorization()
    }

    /// Refreshes today's schedule and notifications.
    func refreshSchedule() {
        guard let location = settings.locationSelection else {
            schedule = nil
            athanScheduler.cancel()
            dailyRefreshTask?.cancel()
            return
        }
        guard location.hasValidCoordinates else {
            schedule = nil
            athanScheduler.cancel()
            dailyRefreshTask?.cancel()
            return
        }
        isLoading = true
        if let schedule = prayerService.schedule(for: location, method: settings.calculationMethod) {
            self.schedule = schedule
            #if !os(tvOS)
            notificationSchedulingTask?.cancel()
            notificationSchedulingTask = Task {
                await notificationService.scheduleNotifications(
                    for: schedule,
                    preferences: settings.notificationPrefs,
                    leadTime: settings.notificationLeadTime
                )
            }
            #endif
            let now = Date()
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = schedule.timeZone
            let currentDayKey = dayKey(for: now, in: schedule.timeZone)
            if lastScheduleDayKey != currentDayKey {
                firedPrayerKeys.removeAll()
                lastScheduleDayKey = currentDayKey
            }
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
            let nextDayEntries = prayerService.entries(for: location, method: settings.calculationMethod, date: tomorrow)
            if schedule.entries.isEmpty {
                athanScheduler.cancel()
                scheduleDailyRefresh(for: schedule.timeZone)
                isLoading = false
                return
            }
            if isAppActive, location.hasResolvedTimeZone {
                athanScheduler.scheduleNextPrayer(
                    from: schedule,
                    nextDayEntries: nextDayEntries,
                    preferences: settings.notificationPrefs,
                    leadTime: settings.notificationLeadTime,
                    now: now
                )
            } else {
                athanScheduler.cancel()
            }
            scheduleDailyRefresh(for: schedule.timeZone)
        } else {
            schedule = nil
            athanScheduler.cancel()
            let currentDayKey = dayKey(for: Date(), in: location.timeZone)
            if lastScheduleDayKey != currentDayKey {
                firedPrayerKeys.removeAll()
                lastScheduleDayKey = currentDayKey
            }
            scheduleDailyRefresh(for: location.timeZone)
        }
        isLoading = false
    }

    private func handleAthanFired(for entry: PrayerTimeEntry, in timeZone: TimeZone) {
        let fireDate = entry.date.addingTimeInterval(TimeInterval(-settings.notificationLeadTime.minutesOffset * 60))
        let key = fireKey(for: entry, fireDate: fireDate, timeZone: timeZone)
        guard !firedPrayerKeys.contains(key) else { return }
        firedPrayerKeys.insert(key)
        shouldShowDashboard = true
        playAthan()
        refreshSchedule()
    }

    private func fireKey(for entry: PrayerTimeEntry, fireDate: Date, timeZone: TimeZone) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: fireDate)
        let dayKey = String(format: "%04d%02d%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
        return "\(entry.kind.rawValue)-\(dayKey)"
    }

    private func dayKey(for date: Date, in timeZone: TimeZone) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d%02d%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    /// Plays Athan immediately.
    func playAthan() {
        athanPlayer.play()
    }


    /// Resets the dashboard navigation request.
    func acknowledgeDashboardRequest() {
        shouldShowDashboard = false
    }

    /// Fetches prayer entries for a specific date.
    func prayerEntries(for location: LocationSelection, on date: Date) -> [PrayerTimeEntry] {
        prayerService.entries(for: location, method: settings.calculationMethod, date: date)
    }

    /// Persists settings to disk.
    private func persistSettings() {
        settingsStore.save(settings)
    }

    private func scheduleDailyRefresh(for timeZone: TimeZone) {
        dailyRefreshTask?.cancel()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let now = Date()
        let startOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        let delay = max(0, startOfTomorrow.timeIntervalSince(now))

        dailyRefreshTask = Task { [weak self] in
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
            self?.firedPrayerKeys.removeAll()
            self?.refreshSchedule()
        }
    }

    /// Observes CoreLocation updates and saves them.
    private func bindLocationUpdates() {
        locationService.$lastLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                guard let self else { return }
                let selection = LocationSelection(
                    name: "Current Location",
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    isCurrentLocation: true,
                    timeZoneIdentifier: nil
                )
                self.updateLocation(selection)
            }
            .store(in: &cancellables)
    }

    private func resolveTimeZoneIfNeeded(for selection: LocationSelection) {
        if let identifier = selection.timeZoneIdentifier,
           !identifier.isEmpty {
            return
        }
        let coordinate = selection.coordinate
        Task { [weak self] in
            guard let timeZone = await self?.locationService.resolveTimeZone(for: coordinate) else {
                return
            }
            await MainActor.run {
                guard let self else { return }
                guard let currentSelection = self.settings.locationSelection,
                      currentSelection.timeZoneIdentifier == nil,
                      self.isSameLocation(currentSelection.coordinate, selection.coordinate) else {
                    return
                }
                var updated = currentSelection
                updated.timeZoneIdentifier = timeZone.identifier
                self.settings.locationSelection = updated
                self.persistSettings()
                self.refreshSchedule()
            }
        }
    }

    private func isSameLocation(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {
        let latitudeDelta = abs(lhs.latitude - rhs.latitude)
        let longitudeDelta = abs(lhs.longitude - rhs.longitude)
        return latitudeDelta < 0.001 && longitudeDelta < 0.001
    }
    
    static var previewValue: AppState {
        let state = AppState()
        state.settings = AppSettings(
            locationSelection: LocationSelection(name: "Preview City", latitude: 40.7128, longitude: -74.0060, isCurrentLocation: false, timeZoneIdentifier: TimeZone.current.identifier),
            calculationMethod: .muslimWorldLeague,
            notificationPrefs: NotificationPreferences(),
            hasCompletedOnboarding: true
        )
        return state
    }
}
