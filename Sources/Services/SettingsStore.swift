import Foundation

/// Manages persistence of user settings in UserDefaults.
final class SettingsStore {
    private let defaults = UserDefaults.standard
    private let settingsKey = "Bilalian.settings"
    private let legacySettingsKey = "AthanTV.settings"

    /// Loads settings from disk or returns defaults.
    func load() -> AppSettings {
        if let data = defaults.data(forKey: settingsKey) {
            return decodeSettings(from: data)
        }
        if let legacyData = defaults.data(forKey: legacySettingsKey) {
            let settings = decodeSettings(from: legacyData)
            save(settings)
            defaults.removeObject(forKey: legacySettingsKey)
            return settings
        }
        return AppSettings()
    }

    /// Saves settings to disk.
    func save(_ settings: AppSettings) {
        guard let data = encodeSettings(settings) else {
            return
        }
        defaults.set(data, forKey: settingsKey)
    }

    private func encodeSettings(_ settings: AppSettings) -> Data? {
        do {
            return try JSONEncoder().encode(settings)
        } catch {
            return nil
        }
    }

    private func decodeSettings(from data: Data) -> AppSettings {
        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            return AppSettings()
        }
    }
}
