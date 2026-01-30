import Foundation

/// Manages persistence of user settings in UserDefaults.
final class SettingsStore {
    private let defaults = UserDefaults.standard
    private let settingsKey = "Bilalian.settings"
    private let legacySettingsKey = "AthanTV.settings"

    /// Loads settings from disk or returns defaults.
    func load() -> AppSettings {
        if let data = defaults.data(forKey: settingsKey) {
            return validate(decodeSettings(from: data))
        }
        if let legacyData = defaults.data(forKey: legacySettingsKey) {
            let settings = validate(decodeSettings(from: legacyData))
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

    private func validate(_ settings: AppSettings) -> AppSettings {
        var validated = settings
        if let location = settings.locationSelection {
            if !location.hasValidCoordinates {
                validated.locationSelection = nil
            } else if let identifier = location.timeZoneIdentifier {
                let trimmed = identifier.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if trimmed.isEmpty || TimeZone(identifier: trimmed) == nil {
                    var updated = location
                    updated.timeZoneIdentifier = nil
                    validated.locationSelection = updated
                }
            }
        }
        return validated
    }
}
