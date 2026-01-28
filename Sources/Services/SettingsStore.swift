import Foundation

final class SettingsStore {
    private let defaults = UserDefaults.standard
    private let settingsKey = "AthanTV.settings"

    func load() -> AppSettings {
        guard let data = defaults.data(forKey: settingsKey) else {
            return AppSettings()
        }
        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            return AppSettings()
        }
    }

    func save(_ settings: AppSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: settingsKey)
        } catch {
            return
        }
    }
}
