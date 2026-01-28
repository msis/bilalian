import SwiftUI
#if os(tvOS)
import UIKit
#endif

@main
struct AthanTVApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .onAppear {
                    #if os(tvOS)
                    UIApplication.shared.isIdleTimerDisabled = true
                    #endif
                }
        }
    }
}
