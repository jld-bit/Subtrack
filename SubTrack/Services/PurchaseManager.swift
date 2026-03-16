import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var hasUnlimitedAccess = false

    let unlimitedProductID = "com.subtrack.unlimited"

    init() {
        Task {
            await loadProducts()
            await updateEntitlements()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [unlimitedProductID])
        } catch {
            products = []
        }
    }

    func purchaseUnlimited() async {
        guard let product = products.first(where: { $0.id == unlimitedProductID }) else { return }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified = verification {
                    await updateEntitlements()
                }
            default:
                break
            }
        } catch {
            // Keep silent; UI remains in current entitlement state.
        }
    }

    func updateEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == unlimitedProductID {
                hasUnlimitedAccess = true
                return
            }
        }
        hasUnlimitedAccess = false
    }
}
