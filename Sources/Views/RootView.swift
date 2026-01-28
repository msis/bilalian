import SwiftUI

/// Entry point that routes to onboarding or dashboard.
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
