import StoreKit
import SwiftUI

struct PremiumShopView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var appModel: AppViewModel
    @EnvironmentObject private var storeService: StoreService
    @State private var didOpenReviewDemoTerms = false
    private let subscriptionProductIDs = [
        "com.voltrushai.premium.monthly",
        "com.voltrushai.premium.yearly"
    ]
    private let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private let privacyURL = URL(string: "https://github.com/lanray07/VoltRush-AI/blob/main/PRIVACY_POLICY.md")!

    var body: some View {
        ZStack {
            ElectricBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    paywallHeader
                    premiumBenefits
                    subscriptionStore
                    productList
                    legalLinks
                }
                .padding(16)
            }
        }
        .voltNavigationTitle("Premium")
        .task {
            await storeService.loadProducts()
            await openTermsForReviewRecordingIfNeeded()
        }
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

    private var subscriptionStore: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(
                    title: "Premium Subscriptions",
                    subtitle: "Monthly Premium and Yearly Premium are handled by Apple's subscription purchase sheet."
                )
                SubscriptionStoreView(productIDs: subscriptionProductIDs) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("VoltRush Premium", systemImage: "bolt.badge.clock.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(VoltTheme.neonYellow)
                        Text("Includes unlimited missions, advanced fault scenarios, AI Mentor, analytics, tournaments, and contractor mode.")
                            .font(.subheadline)
                            .foregroundStyle(VoltTheme.mutedText)
                    }
                }
                .subscriptionStoreControlStyle(.buttons)
                .subscriptionStorePolicyDestination(url: termsURL, for: .termsOfService)
                .subscriptionStorePolicyDestination(url: privacyURL, for: .privacyPolicy)
                .storeButton(.visible, for: .restorePurchases)
                .tint(VoltTheme.neonYellow)
                .onInAppPurchaseCompletion { product, result in
                    await storeService.processSubscriptionStoreCompletion(
                        productName: product.displayName,
                        result: result,
                        appModel: appModel
                    )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Monthly Premium: 1 month, auto-renewable.")
                    Text("Yearly Premium: 1 year, auto-renewable.")
                    Text("Subscriptions renew automatically until cancelled in App Store account settings.")
                    HStack {
                        Link("Terms of Use (EULA)", destination: termsURL)
                        Spacer()
                        Link("Privacy Policy", destination: privacyURL)
                    }
                }
                .font(.caption)
                .foregroundStyle(VoltTheme.mutedText)
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
            SectionTitle(title: "Packs and Coins", subtitle: "One-time packs and consumable coins are securely processed by Apple.")
            ForEach(storeService.products.filter { $0.kind != .autoRenewableSubscription }) { product in
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

    @MainActor
    private func openTermsForReviewRecordingIfNeeded() async {
        guard ReviewDemoMode.isEnabled, !didOpenReviewDemoTerms else { return }
        didOpenReviewDemoTerms = true
        try? await Task.sleep(nanoseconds: 8_000_000_000)
        openURL(termsURL)
    }
}
