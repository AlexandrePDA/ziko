import Foundation
import StoreKit
import Observation

@Observable
final class StoreKitService {
    var isPremium: Bool = false
    var isLoading: Bool = false
    var isLoadingProducts: Bool = false
    var errorMessage: String?
    var isProductAvailable: Bool = false

    private var product: Product?
    private let productID = StoreConfig.premiumProductID

    init() {
        isPremium = UserDefaults.standard.bool(forKey: StorageKeys.isPremium)
        Task { await loadProducts() }
        Task { await verifyEntitlements() }
    }

    func loadProducts() async {
        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        errorMessage = nil
        defer { isLoadingProducts = false }
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
            isProductAvailable = product != nil
            if product == nil {
                errorMessage = "Produit StoreKit introuvable."
            }
        } catch {
            errorMessage = "Chargement impossible : \(error.localizedDescription)"
            isProductAvailable = false
        }
    }

#if DEBUG
    func activatePremiumForTesting() {
        setPremium(true)
    }

    func deactivatePremiumForTesting() {
        setPremium(false)
    }
#endif

    func purchasePremium() async throws {
        guard let product else {
            errorMessage = "Produit non disponible."
            return
        }
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            setPremium(true)
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        try await AppStore.sync()
        await verifyEntitlements()
    }

    func verifyEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productID {
                setPremium(true)
                return
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.unverified
        case .verified(let value):
            return value
        }
    }

    private func setPremium(_ value: Bool) {
        isPremium = value
        UserDefaults.standard.set(value, forKey: StorageKeys.isPremium)
    }
}

enum StoreError: LocalizedError {
    case unverified
    var errorDescription: String? { "Achat non vérifié." }
}
