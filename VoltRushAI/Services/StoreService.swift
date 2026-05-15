import Foundation
import StoreKit

@MainActor
final class StoreService: ObservableObject {
    @Published private(set) var products: [StoreProduct] = MockDataService.shared.storeProducts
    @Published private(set) var availableProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var lastStoreMessage: String?

    private var storeKitProducts: [String: Product] = [:]

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

        do {
            let fetchedProducts = try await Product.products(for: Array(productIDs))
            storeKitProducts = Dictionary(uniqueKeysWithValues: fetchedProducts.map { ($0.id, $0) })
            availableProductIDs = Set(fetchedProducts.map(\.id))
            products = MockDataService.shared.storeProducts.map { localProduct in
                guard let storeProduct = storeKitProducts[localProduct.id] else {
                    return localProduct
                }
                return StoreProduct(
                    id: localProduct.id,
                    displayName: storeProduct.displayName.isEmpty ? localProduct.displayName : storeProduct.displayName,
                    priceText: storeProduct.displayPrice,
                    kind: localProduct.kind,
                    description: localProduct.description,
                    isFeatured: localProduct.isFeatured
                )
            }
        } catch {
            storeKitProducts = [:]
            availableProductIDs = []
            products = MockDataService.shared.storeProducts
            lastStoreMessage = "The App Store is temporarily unavailable. Please try again."
        }
    }

    func purchase(_ product: StoreProduct, appModel: AppViewModel) async {
        isLoading = true
        defer { isLoading = false }

        guard let storeProduct = storeKitProducts[product.id] else {
            lastStoreMessage = "\(product.displayName) is not available from the App Store yet. Please try again later."
            return
        }

        do {
            let result = try await storeProduct.purchase()
            await processPurchaseResult(result, productName: product.displayName, appModel: appModel)
        } catch {
            lastStoreMessage = "The purchase could not be completed. Please try again."
        }
    }

    func processSubscriptionStoreCompletion(productName: String, result: Result<Product.PurchaseResult, any Error>, appModel: AppViewModel) async {
        guard case .success(let purchaseResult) = result else { return }
        await processPurchaseResult(purchaseResult, productName: productName, appModel: appModel)
    }

    func restorePurchases(appModel: AppViewModel) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            var restoredCount = 0
            for await result in Transaction.currentEntitlements {
                let transaction = try checkVerified(result)
                if productIDs.contains(transaction.productID) {
                    applyEntitlement(for: transaction.productID, appModel: appModel)
                    restoredCount += 1
                }
            }
            lastStoreMessage = restoredCount == 0 ? "No previous purchases were found." : "Purchases restored."
        } catch {
            lastStoreMessage = "Restore could not be completed. Please try again."
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreError.failedVerification
        }
    }

    private func processPurchaseResult(_ result: Product.PurchaseResult, productName: String, appModel: AppViewModel) async {
        do {
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                applyEntitlement(for: transaction.productID, appModel: appModel)
                await transaction.finish()
                lastStoreMessage = "\(productName) purchase completed."
            case .pending:
                lastStoreMessage = "\(productName) purchase is pending approval."
            case .userCancelled:
                lastStoreMessage = "Purchase cancelled."
            @unknown default:
                lastStoreMessage = "The purchase could not be completed. Please try again."
            }
        } catch {
            lastStoreMessage = "The purchase could not be verified. Please contact support."
        }
    }

    private func applyEntitlement(for productID: String, appModel: AppViewModel) {
        if productID == "com.voltrushai.coins.small" {
            appModel.addCoins(500)
        } else {
            appModel.setPremiumUnlocked(true)
        }
    }
}

private enum StoreError: Error {
    case failedVerification
}
