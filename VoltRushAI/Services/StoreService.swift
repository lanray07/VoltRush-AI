import Foundation
import StoreKit

@MainActor
final class StoreService: ObservableObject {
    @Published private(set) var products: [StoreProduct] = MockDataService.shared.storeProducts
    @Published var isLoading = false
    @Published var lastStoreMessage: String?

    let productIDs: Set<String> = [
        "com.voltrushai.premium.monthly",
        "com.voltrushai.premium.yearly",
        "com.voltrushai.pack.ukwiring",
        "com.voltrushai.pack.nec",
        "com.voltrushai.pack.solar_ev",
        "com.voltrushai.coins.small"
    ]

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        // TODO: Replace placeholder products with StoreKit.Product.products(for:) after App Store Connect products exist.
        products = MockDataService.shared.storeProducts
    }

    func purchase(_ product: StoreProduct, appModel: AppViewModel) async {
        isLoading = true
        defer { isLoading = false }

        // TODO: Connect to StoreKit purchase flow and validate Transaction.currentEntitlements.
        switch product.kind {
        case .autoRenewableSubscription, .nonConsumable:
            appModel.setPremiumUnlocked(true)
            lastStoreMessage = "\(product.displayName) simulated. Premium features unlocked locally."
        case .consumable:
            appModel.addCoins(500)
            lastStoreMessage = "Coin pack simulated. 500 coins added."
        }
    }

    func restorePurchases(appModel: AppViewModel) async {
        isLoading = true
        defer { isLoading = false }

        // TODO: Call AppStore.sync() and re-check verified entitlements for production.
        appModel.setPremiumUnlocked(appModel.profile.isPremium)
        lastStoreMessage = "Restore checked locally. Connect StoreKit before App Store submission."
    }
}
