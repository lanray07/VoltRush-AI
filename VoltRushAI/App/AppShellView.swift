import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case career
    case lab
    case quiz
    case mentor
    case shop

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .career: "Career"
        case .lab: "Wiring"
        case .quiz: "Quiz"
        case .mentor: "Mentor"
        case .shop: "Shop"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "bolt.fill"
        case .career: "map.fill"
        case .lab: "cable.connector"
        case .quiz: "questionmark.circle.fill"
        case .mentor: "message.fill"
        case .shop: "cart.fill"
        }
    }
}

struct AppShellView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tabContent(tab)
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.systemImage)
                }
                .tag(tab)
            }
        }
        .tint(VoltTheme.neonYellow)
        .toolbarBackground(VoltTheme.surface.opacity(0.96), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }

    @ViewBuilder
    private func tabContent(_ tab: AppTab) -> some View {
        switch tab {
        case .home:
            DashboardView()
        case .career:
            CareerModeView()
        case .lab:
            WiringLabView()
        case .quiz:
            QuizArenaView()
        case .mentor:
            AIMentorView()
        case .shop:
            PremiumShopView()
        }
    }
}
