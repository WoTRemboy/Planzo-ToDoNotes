//  SubscriptionCoordinatorService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.

import Foundation
import StoreKit
import OSLog

private let logger = Logger(subsystem: "com.todonotes.subscription", category: "SubscriptionCoordinatorService")

/// High-level status for UI rendering
enum SubscriptionUIStatus: Equatable {
    case unknown
    case notSubscribed
    case subscribed(expiration: Date?)
    case loading
    case error(String)
}

/// A professional coordinator that orchestrates StoreKit and backend interactions
@MainActor
final class SubscriptionCoordinatorService: ObservableObject {
    static let shared = SubscriptionCoordinatorService()
    
    // Exposed to UI
    @Published private(set) var products: [Product] = []
    @Published private(set) var status: SubscriptionUIStatus = .unknown
    @Published private(set) var purchasingProductId: String? = nil
    @Published private(set) var restoreInProgress: Bool = false
    @Published private(set) var trialEligibility: Bool = false
    
    private let storekit = StoreKitSubscriptionService.shared
    private let backend = SubscriptionNetworkService.shared
    
    private init() {
        // Preload products and status
        loadProducts()
        refreshStatus()
    }
    
    // MARK: - Trial eligibility
    /// Recomputes free trial eligibility for currently loaded products using StoreKit
    private func recomputeTrialEligibility() {
        let currentProducts = self.products
        Task { @MainActor in
            for product in currentProducts {
                if let sub = product.subscription {
                    // Free trial is represented as an introductory offer. Only check eligibility if offer exists.
                    let hasIntro = (sub.introductoryOffer != nil)
                    if hasIntro {
                        let isEligible = await sub.isEligibleForIntroOffer
                        guard !isEligible else {
                            self.trialEligibility = true
                            return
                        }
                    }
                }
            }
            self.trialEligibility = false
        }
    }
    
    // MARK: - Public API for UI
    
    /// Loads StoreKit products
    func loadProducts() {
        status = .loading
        storekit.loadProducts { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let products):
                Task { @MainActor in
                    self.products = products.sorted(by: { $0.displayPrice < $1.displayPrice })
                    self.recomputeTrialEligibility()
                    // Do not override a concrete status here if it was set later
                    if case .loading = self.status { self.status = .unknown }
                }
            case .failure(let error):
                logger.error("Products load failed: \(error.localizedDescription)")
                Task { @MainActor in self.status = .error(error.localizedDescription) }
            }
        }
    }
    
    /// Purchases a product and syncs with backend
    func purchase(productId: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        purchasingProductId = productId
        storekit.purchase(productId: productId) { [weak self] result in
            guard let self = self else { return }
            Task { @MainActor in self.purchasingProductId = nil }
            switch result {
            case .success(let transaction):
                logger.info("Purchase succeeded for productId: \(transaction.productID)")
                let transactionId = String(transaction.id)
                self.backend.attachAppleSubscription(transactionId: transactionId) { attachResult in
                    switch attachResult {
                    case .success(let authResponse):
                        let tokenStorage = TokenStorageService()
                        DispatchQueue.main.async {
                            tokenStorage.save(token: authResponse.accessToken, type: .accessToken)
                            tokenStorage.save(token: authResponse.refreshToken, type: .refreshToken)
                        }
                        self.refreshStatus { backendResult in
                            switch backendResult {
                            case .success:
                                completion?(.success(()))
                            case .failure(let error):
                                completion?(.failure(error))
                            }
                        }
                    case .failure(let error):
                        self.refreshStatus { _ in
                            completion?(.failure(error))
                        }
                    }
                }
                return
            case .failure(let error):
                logger.error("Purchase failed: \(error.localizedDescription)")
                Task { @MainActor in self.status = .error(error.userFacingMessage) }
                completion?(.failure(error))
            }
        }
    }
    
    /// Restores purchases and syncs with backend
    func restorePurchases(completion: ((Result<Void, Error>) -> Void)? = nil) {
        restoreInProgress = true
        self.backend.refreshAppleSubscription { refreshResult in
            switch refreshResult {
            case .success(let authResponse):
                let tokenStorage = TokenStorageService()
                DispatchQueue.main.async {
                    tokenStorage.save(token: authResponse.accessToken, type: .accessToken)
                    tokenStorage.save(token: authResponse.refreshToken, type: .refreshToken)
                }
                self.refreshStatus { backendResult in
                    switch backendResult {
                    case .success:
                        completion?(.success(()))
                    case .failure(let err):
                        completion?(.failure(err))
                    }
                }
            case .failure(let error):
                self.refreshStatus { _ in
                    completion?(.failure(error))
                }
            }
        }
    }
    
    /// Refreshes entitlement from StoreKit and then queries backend license state
    func refreshStatus() {
        status = .loading
        refreshStatus(completion: nil)
    }

    /// Checks across all current StoreKit entitlements whether any purchase is active
    /// - Returns: true if there is at least one active, non-revoked entitlement (subscription or lifetime), otherwise false
    func isAnyProductPurchased() async -> Bool {
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement {
                if transaction.revocationDate == nil {
                    if let exp = transaction.expirationDate {
                        if exp > Date() { return true }
                    } else {
                        return true
                    }
                }
            }
        }
        return false
    }

    /// Convenience wrapper for completion-based callers that checks all entitlements
    func isAnyProductPurchased(completion: @escaping (Bool) -> Void) {
        Task { [weak self] in
            guard let self else { await MainActor.run { completion(false) }; return }
            let purchased = await self.isAnyProductPurchased()
            await MainActor.run { completion(purchased) }
        }
    }
    
    internal func openManageSubscriptions() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                UIApplication.shared.open(url)
            }
            return
        }
        Task {
            do {
                try await AppStore.showManageSubscriptions(in: scene)
            } catch {
                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    // MARK: - Internal Orchestration
    
    internal func refreshStatus(completion: ((Result<Void, Error>) -> Void)?) {
        backend.checkSubscriptionFull { [weak self] backendResult in
            guard let self = self else { return }
            Task { @MainActor in
                switch backendResult {
                case .success(let response):
                    let iso = ISO8601DateFormatter()
                    let backendExpiration = iso.date(from: response.license.validUntil ?? "")

                    if let current = UserCoreDataService.shared.loadUser() {
                        let subscription = Subscription(
                            type: response.license.type,
                            plan: response.license.type,
                            status: response.license.status,
                            validFrom: response.license.validFrom,
                            validUntil: response.license.validUntil,
                            trialUsed: response.license.trialUsed
                        )
                        let updated = User(
                            id: current.id,
                            provider: current.provider,
                            sub: current.sub,
                            createdAt: current.createdAt,
                            name: current.name,
                            email: current.email,
                            avatarUrl: current.avatarUrl,
                            subscription: subscription,
                            lastSyncAt: current.lastSyncAt
                        )
                        UserCoreDataService.shared.saveUser(updated)
                    }

                    if let exp = backendExpiration, exp > Date() || response.license.status.lowercased() == "active" {
                        self.status = .subscribed(expiration: backendExpiration)
                    } else {
                        self.status = .notSubscribed
                    }
                    self.recomputeTrialEligibility()
                    completion?(.success(()))
                case .failure(let error):
                    logger.error("Backend check (refresh) failed: \(error.localizedDescription)")
                    self.status = .error(error.userFacingMessage)
                    self.recomputeTrialEligibility()
                    completion?(.failure(error))
                }
            }
        }
    }
}

// MARK: - Error presentation helper

private extension Error {
    var userFacingMessage: String {
        // Provide nicer messages for common StoreKit errors
        if let skError = self as? StoreKitServiceError {
            switch skError {
            case .userCancelled: return Texts.Subscription.Error.purchaceCancelled
            case .productNotFound: return Texts.Subscription.Error.invalidOffer
            case .failedVerification: return Texts.Subscription.Error.verificationFailed
            case .unknown: return Texts.Subscription.Error.unknown
            }
        }
        return (self as NSError).localizedDescription
    }
}

