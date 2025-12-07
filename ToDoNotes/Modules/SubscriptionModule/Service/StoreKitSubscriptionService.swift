//  StoreKitSubscriptionService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.

import Foundation
import StoreKit
import OSLog

private let skLogger = Logger(subsystem: "com.todonotes.subscription", category: "StoreKitSubscriptionService")

/// Public IDs for subscriptions configured in App Store Connect
/// Update if product identifiers change in ASC
enum ProSubscriptionID: String, CaseIterable {
    case annual = "iOS_todonotes_proaccess_annual_120"
    case monthly = "iOS_todonotes_proaccess_monthly_15"
    case annualTrial = "iOS_todonotes_proaccess_annual_trial_15"
    case monthlyTrial = "iOS_todonotes_proaccess_monthly_trial_15"
}

/// Errors specific to StoreKit operations
enum StoreKitServiceError: Error {
    case failedVerification
    case productNotFound
    case userCancelled
    case unknown
}

/// StoreKit 2 subscription service built with completion-style API to match other NetworkService classes
final class StoreKitSubscriptionService: ObservableObject {
    static let shared = StoreKitSubscriptionService()
    
    @Published private(set) var availableProducts: [Product] = []
    @Published private(set) var isSubscribed: Bool = false
    @Published private(set) var currentTransaction: Transaction? = nil
    
    private init() {
        // Start listening for transaction updates
        listenForTransactions()
        // Pre-calc current status
        refreshSubscriptionStatus { _ in }
    }
    
    // MARK: - Products
    
    /// Loads subscription products from the App Store
    func loadProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        Task {
            do {
                let products = try await Product.products(for: ProSubscriptionID.allCases.map { $0.rawValue })
                await MainActor.run {
                    self.availableProducts = products
                }
                skLogger.info("Loaded StoreKit products: \(products.map { $0.id }.joined(separator: ", "))")
                completion(.success(products))
            } catch {
                skLogger.error("Failed to load StoreKit products: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    /// Returns a product by id if it is already loaded
    func product(with id: String) -> Product? {
        availableProducts.first { $0.id == id }
    }
    
    // MARK: - Purchase
    
    /// Purchases a subscription by product id
    func purchase(productId: String, completion: @escaping (Result<Transaction, Error>) -> Void) {
        Task {
            do {
                let product: Product
                if let loaded = self.product(with: productId) {
                    product = loaded
                } else {
                    let fetched = try await Product.products(for: [productId])
                    guard let first = fetched.first else { throw StoreKitServiceError.productNotFound }
                    product = first
                }
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    let transaction = try self.checkVerified(verification)
                    await transaction.finish()
                    await self.updateEntitlements(using: transaction)
                    completion(.success(transaction))
                case .userCancelled:
                    completion(.failure(StoreKitServiceError.userCancelled))
                case .pending:
                    // Pending means SCA or approval; do not fail, but report unknown/pending
                    completion(.failure(StoreKitServiceError.unknown))
                @unknown default:
                    completion(.failure(StoreKitServiceError.unknown))
                }
            } catch {
                skLogger.error("Purchase failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Restore
    
    /// Triggers App Store restore flow and refreshes local entitlements
    func restorePurchases(completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                try await AppStore.sync()
                // After sync, recalc entitlements
                let status = try await self.calculateIsSubscribed()
                await MainActor.run { self.isSubscribed = status }
                completion(.success(status))
            } catch {
                skLogger.error("Restore failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Status
    
    /// Refreshes current subscription flag
    func refreshSubscriptionStatus(completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            do {
                let status = try await self.calculateIsSubscribed()
                await MainActor.run { self.isSubscribed = status }
                completion(.success(status))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Returns active transaction for our subscription group, if any
    func currentEntitlement(completion: @escaping (Result<Transaction?, Error>) -> Void) {
        Task {
            do {
                let entitlement = try await self.fetchCurrentEntitlement()
                completion(.success(entitlement))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Internal helpers
    
    private func listenForTransactions() {
        Task.detached(priority: .background) { [weak self] in
            for await update in Transaction.updates {
                guard let self = self else { continue }
                do {
                    let transaction = try self.checkVerified(update)
                    await transaction.finish()
                    await self.updateEntitlements(using: transaction)
                } catch {
                    skLogger.error("Transaction update verification failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    private func updateEntitlements(using transaction: Transaction) async {
        self.currentTransaction = transaction
        do {
            let status = try await self.calculateIsSubscribed()
            self.isSubscribed = status
        } catch {
            skLogger.error("Failed to update entitlements after transaction: \(error.localizedDescription)")
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let signedType):
            return signedType
        }
    }
    
    private func calculateIsSubscribed() async throws -> Bool {
        // Look through current entitlements for any of our product IDs
        for await entitlement in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(entitlement)
                if ProSubscriptionID.allCases.map({ $0.rawValue }).contains(transaction.productID) {
                    // Ensure not revoked and not expired
                    if transaction.revocationDate == nil, transaction.expirationDate == nil || (transaction.expirationDate ?? .distantPast) > Date() {
                        return true
                    }
                }
            } catch {
                continue
            }
        }
        return false
    }
    
    private func fetchCurrentEntitlement() async throws -> Transaction? {
        for await entitlement in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(entitlement)
                if ProSubscriptionID.allCases.map({ $0.rawValue }).contains(transaction.productID) {
                    return transaction
                }
            } catch {
                continue
            }
        }
        return nil
    }
}

