//  SubscriptionNetworkService.swift
//  ToDoNotes
//
//  Created by Assistant on 17/09/2025.

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.todonotes.subscription", category: "SubscriptionNetworkService")

/// Errors related to the subscription API
enum SubscriptionAPIError: Error {
    /// The response from the server was invalid or unexpected
    case invalidResponse
    /// A network error occurred during the request
    case network(Error)
    /// Failed to decode the response data
    case decoding(Error)
    /// Access token was not found or missing
    case missingToken
}

/// A response containing subscription information and license details returned from the server
struct SubscriptionResponse: Codable {
    /// License information for the subscription
    struct License: Codable {
        /// The date and time until which the license is valid
        let validUntil: String
        /// The date and time from which the license is valid
        let validFrom: String
        /// The type of license
        let type: String
        /// The subscription plan associated with the license
        let plan: String
        /// The current status of the license
        let status: String
    }
    
    /// License data associated with the subscription
    let license: License
    /// Subscription identifier or subject
    let sub: String
}

/// Сервис для работы с подписками
final class SubscriptionNetworkService {
    static let shared = SubscriptionNetworkService()
    private let tokenStorage = TokenStorageService()
    
    /// Starts a free trial for the user
    /// - Parameter days: Duration of the trial period in days (default is 14)
    /// - Returns: An updated `AuthResponse` containing a new access token and user subscription information
    /// - Throws: `SubscriptionAPIError` if the token is missing, network request fails, response is invalid, or decoding fails
    func startTrial(days: Int = 14) async throws -> AuthResponse {
        guard let accessToken = tokenStorage.load(type: .accessToken) else {
            logger.error("Missing access token when trying to start trial")
            throw SubscriptionAPIError.missingToken
        }
        var components = URLComponents(string: "https://banana.avoqode.com/api/v1/subscription/trial")!
        components.queryItems = [
            URLQueryItem(name: "days", value: String(days))
        ]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                logger.error("Invalid response when starting trial: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                throw SubscriptionAPIError.invalidResponse
            }
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                print(authResponse)
                logger.info("Successfully started trial for \(days) days")
                return authResponse
            } catch {
                logger.error("Decoding error when starting trial: \(error.localizedDescription)")
                throw SubscriptionAPIError.decoding(error)
            }
        } catch {
            logger.error("Network error when starting trial: \(error.localizedDescription)")
            throw SubscriptionAPIError.network(error)
        }
    }
    
    /// Checks the current subscription status of the user.
    /// - Returns: A `SubscriptionResponse` containing subscription license data and subscription identifier.
    /// - Throws: `SubscriptionAPIError` if the token is missing, network request fails, response is invalid, or decoding fails.
    func checkSubscription() async throws -> SubscriptionResponse {
        guard let accessToken = tokenStorage.load(type: .accessToken) else {
            logger.error("Missing access token when trying to check subscription status")
            throw SubscriptionAPIError.missingToken
        }
        
        let url = URL(string: "https://banana.avoqode.com/api/v1/subscription/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print(String(data: data, encoding: .utf8)!)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                logger.error("Invalid response when checking subscription: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                throw SubscriptionAPIError.invalidResponse
            }
            do {
                let decoder = JSONDecoder()
                let subscriptionStatus = try decoder.decode(SubscriptionResponse.self, from: data)
                logger.info("Successfully fetched subscription status")
                return subscriptionStatus
            } catch {
                logger.error("Decoding error when checking subscription: \(error.localizedDescription)")
                throw SubscriptionAPIError.decoding(error)
            }
        } catch {
            logger.error("Network error when checking subscription: \(error.localizedDescription)")
            throw SubscriptionAPIError.network(error)
        }
    }
}

