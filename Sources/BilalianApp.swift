import SwiftUI
#if os(tvOS)
import UIKit
#endif

/// App entry point.
@main
struct BilalianApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .onChange(of: scenePhase) { _, phase in
                    appState.setAppActive(phase == .active)
                }
                .onAppear {
                    #if os(tvOS)
                    UIApplication.shared.isIdleTimerDisabled = true
                    #endif
                }
        }
    }
}
