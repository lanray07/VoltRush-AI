import SwiftUI

@main
struct VoltRushAIApp: App {
    @StateObject private var appModel = AppViewModel()
    @StateObject private var storeService = StoreService()

    var body: some Scene {
        WindowGroup {
            RootEntryView()
                .environmentObject(appModel)
                .environmentObject(storeService)
                .preferredColorScheme(.dark)
        }
    }
}

private struct RootEntryView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding || ReviewDemoMode.isEnabled {
                AppShellView()
            } else {
                OnboardingView()
            }
        }
        .background(VoltTheme.background.ignoresSafeArea())
    }
}

enum ReviewDemoMode {
    static var isEnabled: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("--review-paywall-demo")
        #else
        false
        #endif
    }
}
