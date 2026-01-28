import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var settings: AppSettings
    @Published var schedule: PrayerSchedule?
    @Published var nextPrayer: PrayerTimeEntry?
    @Published var isLoading = false

    let locationService = LocationService()
    let citySearchService = CitySearchService()

    private let settingsStore = SettingsStore()
    private let prayerService = PrayerTimeService()
    private let notificationService = NotificationService()

    private var cancellables = Set<AnyCancellable>()

    init() {
        settings = settingsStore.load()
        bindLocationUpdates()
        Task {
            await notificationService.requestAuthorization()
        }
    }

    func completeOnboarding() {
        settings.hasCompletedOnboarding = true
        persistSettings()
        refreshSchedule()
    }

    func updateLocation(_ selection: LocationSelection) {
        settings.locationSelection = selection
        persistSettings()
        refreshSchedule()
    }

    func updateCalculationMethod(_ method: CalculationMethodOption) {
        settings.calculationMethod = method
        persistSettings()
        refreshSchedule()
    }

    func updateNotificationPreference(_ kind: PrayerKind, enabled: Bool) {
        settings.notificationPrefs.setEnabled(enabled, for: kind)
        persistSettings()
        refreshSchedule()
    }

    func requestLocation() {
        locationService.requestAuthorization()
    }

    func refreshSchedule() {
        guard let location = settings.locationSelection else {
            schedule = nil
            nextPrayer = nil
            return
        }
        isLoading = true
        if let schedule = prayerService.schedule(for: location, method: settings.calculationMethod) {
            self.schedule = schedule
            nextPrayer = NextPrayerCalculator.nextPrayer(from: schedule.entries)
            Task {
                await notificationService.scheduleNotifications(for: schedule, preferences: settings.notificationPrefs)
            }
        }
        isLoading = false
    }

    func prayerEntries(for location: LocationSelection, on date: Date) -> [PrayerTimeEntry] {
        prayerService.entries(for: location, method: settings.calculationMethod, date: date)
    }

    private func persistSettings() {
        settingsStore.save(settings)
    }

    private func bindLocationUpdates() {
        locationService.$lastLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                let selection = LocationSelection(
                    name: "Current Location",
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    isCurrentLocation: true
                )
                self?.updateLocation(selection)
            }
            .store(in: &cancellables)
    }
    
    static var previewValue: AppState {
        let state = AppState()
        state.settings = AppSettings(
            locationSelection: LocationSelection(name: "Preview City", latitude: 40.7128, longitude: -74.0060, isCurrentLocation: false),
            calculationMethod: .muslimWorldLeague,
            notificationPrefs: NotificationPreferences(),
            hasCompletedOnboarding: true
        )
        return state
    }
}

