import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.settings.hasCompletedOnboarding {
                DashboardView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}

