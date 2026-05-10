import SwiftUI

enum VoltTheme {
    static let background = Color(red: 0.03, green: 0.05, blue: 0.08)
    static let surface = Color(red: 0.07, green: 0.10, blue: 0.15)
    static let elevated = Color(red: 0.10, green: 0.15, blue: 0.22)
    static let neonBlue = Color(red: 0.12, green: 0.72, blue: 1.00)
    static let neonYellow = Color(red: 1.00, green: 0.85, blue: 0.21)
    static let success = Color(red: 0.21, green: 0.86, blue: 0.55)
    static let warning = Color(red: 1.00, green: 0.56, blue: 0.20)
    static let danger = Color(red: 1.00, green: 0.24, blue: 0.34)
    static let purple = Color(red: 0.62, green: 0.43, blue: 1.00)
    static let mutedText = Color.white.opacity(0.68)

    static let electricGradient = LinearGradient(
        colors: [neonBlue, neonYellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct ElectricBackground: View {
    var body: some View {
        ZStack {
            VoltTheme.background
            LinearGradient(
                colors: [
                    VoltTheme.neonBlue.opacity(0.18),
                    .clear,
                    VoltTheme.neonYellow.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}

extension View {
    func voltNavigationTitle(_ title: String) -> some View {
        navigationTitle(title)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(VoltTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}
