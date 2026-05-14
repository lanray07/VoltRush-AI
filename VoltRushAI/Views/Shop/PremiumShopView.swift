import SwiftUI

struct PremiumShopView: View {
    @EnvironmentObject private var appModel: AppViewModel
    @EnvironmentObject private var storeService: StoreService
    private let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private let privacyURL = URL(string: "https://github.com/lanray07/VoltRush-AI/blob/main/PRIVACY_POLICY.md")!

    var body: some View {
        ZStack {
            ElectricBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    paywallHeader
                    premiumBenefits
                    productList
                    legalLinks
                }
                .padding(16)
            }
        }
        .voltNavigationTitle("Premium")
        .task { await storeService.loadProducts() }
        .alert("Store", isPresented: .constant(storeService.lastStoreMessage != nil), actions: {
            Button("OK") { storeService.lastStoreMessage = nil }
        }, message: {
            Text(storeService.lastStoreMessage ?? "")
        })
    }

    private var paywallHeader: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("VoltRush Premium", systemImage: "bolt.badge.clock.fill")
                    .font(.title.weight(.bold))
                    .foregroundStyle(VoltTheme.neonYellow)
                Text("Unlock advanced learning modes with transparent pricing and no hidden real-world certification claims.")
                    .foregroundStyle(VoltTheme.mutedText)
                if appModel.profile.isPremium {
                    Label("Premium unlocked locally", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(VoltTheme.success)
                }
            }
        }
    }

    private var premiumBenefits: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Premium Unlocks")
                ForEach([
                    "Unlimited missions",
                    "Advanced fault scenarios",
                    "AI Mentor",
                    "Certification packs",
                    "PvP tournaments",
                    "Contractor business mode",
                    "Detailed progress analytics"
                ], id: \.self) { benefit in
                    Label(benefit, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(VoltTheme.mutedText)
                }
            }
        }
    }

    private var productList: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Products", subtitle: "Purchases are securely processed by Apple. Subscription prices, durations, renewal details, and legal links are shown before purchase.")
            ForEach(storeService.products) { product in
                NeonCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(product.priceText)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(product.isFeatured ? VoltTheme.neonYellow : VoltTheme.neonBlue)
                            }
                            Spacer()
                            if product.isFeatured {
                                Text("Featured")
                                    .font(.caption.weight(.bold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(VoltTheme.neonYellow, in: Capsule())
                                    .foregroundStyle(.black)
                            }
                        }
                        Text(product.description)
                            .font(.subheadline)
                            .foregroundStyle(VoltTheme.mutedText)
                        if product.kind == .autoRenewableSubscription {
                            subscriptionTerms(for: product)
                        }
                        Text(product.id)
                            .font(.caption2.monospaced())
                            .foregroundStyle(VoltTheme.mutedText.opacity(0.75))
                        PrimaryActionButton(title: "Choose", systemImage: "cart.fill") {
                            Task { await storeService.purchase(product, appModel: appModel) }
                        }
                        .disabled(storeService.isLoading)
                    }
                }
            }

            Button {
                Task { await storeService.restorePurchases(appModel: appModel) }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(VoltTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
        }
    }

    private var legalLinks: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Subscriptions renew automatically unless cancelled in App Store account settings. All purchases use Apple's in-app purchase system.")
                    .font(.footnote)
                    .foregroundStyle(VoltTheme.mutedText)
                HStack {
                    Link("Terms of Use (EULA)", destination: termsURL)
                    Spacer()
                    Link("Privacy Policy", destination: privacyURL)
                }
                .foregroundStyle(VoltTheme.neonBlue)
            }
        }
    }

    @ViewBuilder
    private func subscriptionTerms(for product: StoreProduct) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Auto-renewable subscription", systemImage: "repeat.circle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(VoltTheme.neonBlue)
            Text("Length: \(subscriptionLength(for: product))")
            Text("Price: \(product.priceText)")
            Text("Renews automatically until cancelled. Manage or cancel in your App Store account settings.")
            HStack {
                Link("Terms of Use (EULA)", destination: termsURL)
                Spacer()
                Link("Privacy Policy", destination: privacyURL)
            }
        }
        .font(.caption)
        .foregroundStyle(VoltTheme.mutedText)
        .padding(10)
        .background(VoltTheme.surface.opacity(0.7), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func subscriptionLength(for product: StoreProduct) -> String {
        switch product.id {
        case "com.voltrushai.premium.monthly":
            return "1 month"
        case "com.voltrushai.premium.yearly":
            return "1 year"
        default:
            return "Shown on the App Store purchase sheet"
        }
    }
}
