import StoreKit
import Foundation
import Observation

@Observable
class PurchaseService {
    static let productID = "com.keisukearai.task-count-down.premium"

    private(set) var isPremium: Bool = false
    private var listenerTask: Task<Void, Never>?

    init() {
        listenerTask = Task {
            await checkCurrentEntitlements()
            await listenForTransactions()
        }
    }

    deinit {
        listenerTask?.cancel()
    }

    func purchase() async throws {
        let products = try await Product.products(for: [Self.productID])
        guard let product = products.first else {
            throw PurchaseError.productNotFound
        }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            isPremium = true
            await transaction.finish()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }

    func restore() async throws {
        try await AppStore.sync()
        await checkCurrentEntitlements()
    }

    func loadProduct() async -> Product? {
        try? await Product.products(for: [Self.productID]).first
    }

    private func checkCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                isPremium = true
                return
            }
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await transaction.finish()
                if transaction.productID == Self.productID {
                    isPremium = transaction.revocationDate == nil
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let value):
            return value
        }
    }

    enum PurchaseError: LocalizedError {
        case productNotFound
        case failedVerification

        var errorDescription: String? {
            switch self {
            case .productNotFound:
                return String(localized: "error_product_not_found")
            case .failedVerification:
                return String(localized: "error_verification_failed")
            }
        }
    }
}
