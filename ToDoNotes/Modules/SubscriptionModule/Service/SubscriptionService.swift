import Foundation
import OSLog

private let logger = Logger(subsystem: "com.todonotes.subscription", category: "SubscriptionService")

final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    private let network = SubscriptionNetworkService()
    private let tokenStorage = TokenStorageService()
    
    /// Refreshes the subscription status from the network and updates the local user subscription accordingly.
    /// - Parameter authService: The authentication service managing the current user.
    /// - Returns: The updated `SubscriptionType` reflecting the current subscription status.
    @discardableResult
    func refreshStatus(authService: AuthNetworkService) async throws -> SubscriptionType {
        logger.debug("Starting subscription status refresh.")
        let response = try await network.checkSubscription()
        
        let subscriptionType: SubscriptionType
        if response.license.status.lowercased() == "active" {
            subscriptionType = .pro
        } else {
            subscriptionType = .free
        }
        
        await MainActor.run {
            guard var currentUser = authService.currentUser else {
                logger.debug("No current user found to update subscription status.")
                return
            }
            // Create a new user instance with updated subscription since `changeSubscriptionType(to:)` mutating extension is referenced as logic inline
            var updatedUser = currentUser
            updatedUser.subscription = subscriptionType
            authService.currentUser = updatedUser
            
            UserCoreDataService.shared.saveUser(updatedUser)
            logger.debug("Updated current user subscription to \(subscriptionType.rawValue).")
        }
        
        logger.debug("Subscription status refresh completed with status: \(subscriptionType.rawValue).")
        return subscriptionType
    }
    
    /// Starts a trial subscription for the specified number of days.
    /// - Parameters:
    ///   - days: The length of the trial in days. Defaults to 14.
    ///   - authService: The authentication service managing the current user.
    func startTrial(days: Int = 14, authService: AuthNetworkService) async throws {
        logger.debug("Starting trial subscription for \(days) days.")
        let authResponse = try await network.startTrial(days: days)
        
        tokenStorage.save(token: authResponse.accessToken, type: .accessToken)
        tokenStorage.save(token: authResponse.refreshToken, type: .refreshToken)
        
        let type = try await refreshStatus(authService: authService)
        logger.debug("Trial started successfully with subscription type: \(type.rawValue).")
    }
    
    /// Grants a pro subscription plan valid until the specified date.
    /// - Parameters:
    ///   - plan: The subscription plan identifier.
    ///   - validUntil: The date until which the pro subscription is valid.
    ///   - authService: The authentication service managing the current user.
    func grantPro(plan: String, validUntil: Date, authService: AuthNetworkService) async throws {
        logger.debug("Granting pro subscription plan '\(plan)' valid until \(validUntil).")
        _ = try await network.grantPro(plan: plan, validUntil: validUntil)
        
        let type = try await refreshStatus(authService: authService)
        logger.debug("Pro subscription granted successfully with subscription type: \(type.rawValue).")
    }
}
