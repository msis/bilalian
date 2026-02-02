import SwiftUI

/// Settings for notifications, location, and calculation method.
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    private func notificationBinding(for kind: PrayerKind) -> Binding<Bool> {
        Binding(get: {
            appState.settings.notificationPrefs.isEnabled(for: kind)
        }, set: { enabled in
            appState.updateNotificationPreference(kind, enabled: enabled)
        })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Notifications
                VStack(alignment: .leading, spacing: 16) {
                    Text(notificationsTitle)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 16) {
                        ForEach(PrayerKind.allCases.filter { $0.isNotifiable }) { kind in
                            Toggle(kind.displayName, isOn: notificationBinding(for: kind))
                        }
                    }
                    
                    HStack {
                        Text("Alert timing")
                        Spacer()
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
                        .pickerStyle(.menu)
                    }

                    Text(notificationFootnote)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                // Location
                VStack(alignment: .leading, spacing: 16) {
                    Text("Location")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text(appState.settings.locationSelection?.name ?? "Not set")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)

                        NavigationLink {
                            CitySearchView { selection in
                                appState.updateLocation(selection)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Text("Change City")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                        }
                        .buttonStyle(.card)

                        Button {
                            appState.requestLocation()
                        } label: {
                            HStack {
                                Text("Use My Location")
                                Spacer()
                                Image(systemName: "location")
                            }
                            .padding()
                        }
                        .buttonStyle(.card)
                    }
                    
                    Text("Your location is used locally to calculate accurate prayer times for your area.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Calculation Method
                VStack(alignment: .leading, spacing: 16) {
                    Text("Calculation Method")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 16) {
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
                                .padding()
                            }
                            .buttonStyle(.card)
                        }
                    }
                }
            }
            .padding(40)
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
