import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Notifications") {
                ForEach(PrayerKind.allCases.filter { $0.isNotifiable }) { kind in
                    Toggle(kind.displayName, isOn: Binding(get: {
                        appState.settings.notificationPrefs.isEnabled(for: kind)
                    }, set: { enabled in
                        appState.updateNotificationPreference(kind, enabled: enabled)
                    }))
                }
            }

            Section("Location") {
                Text(appState.settings.locationSelection?.name ?? "Not set")
                NavigationLink("Change City") {
                    CitySearchView { selection in
                        appState.updateLocation(selection)
                        dismiss()
                    }
                }
                Button("Use My Location") {
                    appState.requestLocation()
                }
            }

            Section("Calculation Method") {
                ForEach(CalculationMethodOption.allCases) { option in
                    Button {
                        appState.updateCalculationMethod(option)
                        dismiss()
                    } label: {
                        HStack {
                            Text(option.displayName)
                            Spacer()
                            if option == appState.settings.calculationMethod {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState.previewValue)
    }
}

