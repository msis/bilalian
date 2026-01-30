import SwiftUI

/// Settings for notifications, location, and calculation method.
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Namespace private var focusScope

    private func notificationBinding(for kind: PrayerKind) -> Binding<Bool> {
        Binding(get: {
            appState.settings.notificationPrefs.isEnabled(for: kind)
        }, set: { enabled in
            appState.updateNotificationPreference(kind, enabled: enabled)
        })
    }

    var body: some View {
        Form {
            Section(notificationsTitle) {
                ForEach(PrayerKind.allCases.filter { $0.isNotifiable }) { kind in
                    Toggle(kind.displayName, isOn: notificationBinding(for: kind))
                }

                Picker("Alert timing", selection: Binding(get: {
                    appState.settings.notificationLeadTime
                }, set: { leadTime in
                    appState.updateNotificationLeadTime(leadTime)
                })) {
                    ForEach(NotificationLeadTime.allCases) { option in
                        Text(option.displayName)
                            .tag(option)
                    }
                }
                Text(notificationFootnote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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

    private var notificationsTitle: String {
        #if os(tvOS)
        return "Athan Alerts"
        #else
        return "Notifications"
        #endif
    }

    private var notificationFootnote: String {
        #if os(tvOS)
        return "Athan alerts play in-app audio only. Keep the app open."
        #else
        return "Enable notifications to receive alerts."
        #endif
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState.previewValue)
    }
}
