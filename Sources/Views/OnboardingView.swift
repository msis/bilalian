import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSearch = false

    var body: some View {
        VStack(spacing: 24) {
            Text("AthanTV")
                .font(.largeTitle)
                .bold()
            Text("Get prayer times based on your location.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            HStack(spacing: 24) {
                Button("Use My Location") {
                    appState.requestLocation()
                }
                .buttonStyle(.borderedProminent)

                Button("Search City") {
                    showSearch = true
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 12)

            if let selection = appState.settings.locationSelection {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(selection.name)
                    }
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .focusable(false)
                    Button("Continue") {
                        appState.completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 24)
            }
        }
        .padding(48)
        .sheet(isPresented: $showSearch) {
            CitySearchView { selection in
                appState.updateLocation(selection)
                showSearch = false
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}

