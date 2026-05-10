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
            if hasCompletedOnboarding {
                AppShellView()
            } else {
                OnboardingView()
            }
        }
        .background(VoltTheme.background.ignoresSafeArea())
    }
}
