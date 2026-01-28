import Foundation

/// Manages persistence of user settings in UserDefaults.
final class SettingsStore {
    private let defaults = UserDefaults.standard
    private let settingsKey = "AthanTV.settings"

    /// Loads settings from disk or returns defaults.
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

    /// Saves settings to disk.
    func save(_ settings: AppSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: settingsKey)
        } catch {
            return
        }
    }
}
