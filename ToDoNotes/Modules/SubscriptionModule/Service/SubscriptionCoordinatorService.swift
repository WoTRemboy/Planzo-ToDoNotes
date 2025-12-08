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
    
    private let storekit = StoreKitSubscriptionService.shared
    private let backend = SubscriptionNetworkService.shared
    
    private init() {
        // Preload products and status
        loadProducts()
        refreshStatus()
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
                // If the purchased product includes a free trial, start the backend trial instead of granting PRO immediately
                if productId == ProSubscriptionID.annualTrial.rawValue || productId == ProSubscriptionID.monthlyTrial.rawValue {
                    self.backend.startTrial(days: 7) { trialResult in
                        switch trialResult {
                        case .success:
                            self.refreshStatusFromBoth { backendResult in
                                switch backendResult {
                                case .success:
                                    completion?(.success(()))
                                case .failure(let error):
                                    completion?(.failure(error))
                                }
                            }
                        case .failure(let error):
                            self.refreshStatusFromBoth { _ in
                                completion?(.failure(error))
                            }
                        }
                    }
                    return
                }
                if let expiration = transaction.expirationDate {
                    let iso = ISO8601DateFormatter().string(from: expiration)
                    self.backend.grantPro(plan: "PRO", validUntil: iso) { grantResult in
                        switch grantResult {
                        case .success:
                            self.refreshStatusFromBoth { backendResult in
                                switch backendResult {
                                case .success:
                                    completion?(.success(()))
                                case .failure(let err):
                                    completion?(.failure(err))
                                }
                            }
                        case .failure(let err):
                            self.refreshStatusFromBoth { _ in
                                completion?(.failure(err))
                            }
                        }
                    }
                } else {
                    self.refreshStatusFromBoth { backendResult in
                        switch backendResult {
                        case .success:
                            completion?(.success(()))
                        case .failure(let err):
                            completion?(.failure(err))
                        }
                    }
                }
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
        storekit.restorePurchases { [weak self] result in
            guard let self = self else { return }
            Task { @MainActor in self.restoreInProgress = false }
            switch result {
            case .success(_):
                self.refreshStatusFromBoth { backendResult in
                    switch backendResult {
                    case .success:
                        completion?(.success(()))
                    case .failure(let err):
                        completion?(.failure(err))
                    }
                }
            case .failure(let error):
                logger.error("Restore failed: \(error.localizedDescription)")
                Task { @MainActor in self.status = .error(error.userFacingMessage) }
                completion?(.failure(error))
            }
        }
    }
    
    /// Refreshes entitlement from StoreKit and then queries backend license state
    func refreshStatus() {
        status = .loading
        refreshStatusFromBoth(completion: nil)
    }
    
    // MARK: - Internal Orchestration
    
    internal func refreshStatusFromBoth(completion: ((Result<Void, Error>) -> Void)?) {
        storekit.refreshSubscriptionStatus { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.storekit.currentEntitlement { entitlementResult in
                    switch entitlementResult {
                    case .success(let transaction):
                        let localExpiration = transaction?.expirationDate
                        Task { @MainActor in self.checkSubscriptionAndUpdateState(localExpiration: localExpiration, completion: completion) }
                    case .failure:
                        // If we can't fetch entitlement, proceed without local expiration
                        Task { @MainActor in self.checkSubscriptionAndUpdateState(localExpiration: nil, completion: completion) }
                    }
                }
            case .failure(let error):
                logger.error("Local entitlement check failed: \(error.localizedDescription)")
                Task { @MainActor in
                    self.status = .error(error.userFacingMessage)
                    completion?(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Backend helpers
    
    internal func checkSubscriptionAndUpdateState(localExpiration: Date? = nil, completion: ((Result<Void, Error>) -> Void)?) {
        backend.checkSubscription { backendResult in
            Task { @MainActor in
                switch backendResult {
                case .success(let response):
                    let isoFormatter = ISO8601DateFormatter()
                    let backendExpiration = isoFormatter.date(from: response.license.validUntil ?? "")
                    let backendExp = backendExpiration ?? Date.distantPast
                    
                    // If both local and backend expirations are in the past, treat as not subscribed and clear persisted subscription
                    if let localExp = localExpiration {
                        let now = Date()
                        if localExp < now && backendExp < now {
                            self.status = .notSubscribed
                            if let current = UserCoreDataService.shared.loadUser() {
                                let updated = User(
                                    id: current.id,
                                    provider: current.provider,
                                    sub: current.sub,
                                    createdAt: current.createdAt,
                                    name: current.name,
                                    email: current.email,
                                    avatarUrl: current.avatarUrl,
                                    subscription: nil,
                                    lastSyncAt: current.lastSyncAt
                                )
                                UserCoreDataService.shared.saveUser(updated)
                            }
                            completion?(.success(()))
                            return
                        }
                    }

                    @MainActor func persistAndPublish(from resp: SubscriptionResponse) {
                        let expiration = isoFormatter.date(from: resp.license.validUntil ?? "")
                        self.status = .subscribed(expiration: expiration)
                        logger.info("Backend subscription status: \(resp.license.status) plan = \(resp.license.plan) until = \(resp.license.validUntil ?? "")")
                        // Persist updated subscription to Core Data
                        if let current = UserCoreDataService.shared.loadUser() {
                            let subscription = Subscription(
                                type: resp.license.type,
                                plan: resp.license.plan,
                                status: resp.license.status,
                                validFrom: resp.license.validFrom,
                                validUntil: resp.license.validUntil,
                                trialUsed: resp.license.trialUsed
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
                    }

                    // Determine if server needs to be updated with a later local expiration
                    if let localExp = localExpiration, localExp > backendExp.addingTimeInterval(10) {
                        let newValidUntil = isoFormatter.string(from: localExp)
                        logger.info("Local entitlement expiration (\(newValidUntil)) is later than backend (\(response.license.validUntil ?? "")). Updating server...")
                        self.backend.grantPro(plan: "PRO", validUntil: newValidUntil) { grantResult in
                            switch grantResult {
                            case .success:
                                // Re-fetch to ensure consistency and then persist
                                self.backend.checkSubscription { refreshResult in
                                    Task { @MainActor in
                                        switch refreshResult {
                                        case .success(let refreshed):
                                            persistAndPublish(from: refreshed)
                                            completion?(.success(()))
                                        case .failure(let err):
                                            self.status = .subscribed(expiration: localExp)
                                            logger.error("Backend re-check after grant failed: \(err.localizedDescription)")
                                            completion?(.failure(err))
                                        }
                                    }
                                }
                            case .failure(let err):
                                Task { @MainActor in
                                    self.status = .subscribed(expiration: localExp)
                                    logger.error("Failed to update backend validUntil: \(err.localizedDescription)")
                                    completion?(.failure(err))
                                }
                            }
                        }
                    } else {
                        // No update needed; publish current backend state
                        persistAndPublish(from: response)
                        completion?(.success(()))
                    }
                case .failure(let error):
                    // Fallback to local entitlement if backend fails
                    logger.error("Backend check failed: \(error.localizedDescription)")
                    self.status = .subscribed(expiration: nil)
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

