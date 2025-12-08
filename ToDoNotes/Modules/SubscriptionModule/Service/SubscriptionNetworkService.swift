//  SubscriptionNetworkService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.

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
        let validUntil: String?
        /// The date and time from which the license is valid
        let validFrom: String
        /// The type of license
        let type: String
        /// The subscription plan associated with the license
        let plan: String
        /// The current status of the license
        let status: String
        let trialUsed: Bool
    }
    
    /// License data associated with the subscription
    let license: License
    /// Subscription identifier or subject
    let sub: String
}

final class SubscriptionNetworkService {
    static let shared = SubscriptionNetworkService()
    
    // MARK: - Trial
    
    /// Starts a free trial for the user
    /// - Parameters:
    ///   - days: Duration of the trial period in days (default is 14)
    ///   - completion: Result with `AuthResponse` or `Error`
    internal func startTrial(days: Int = 7, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                var components = URLComponents(string: "https://banana.avoqode.com/api/v1/subscription/trial")!
                components.queryItems = [ URLQueryItem(name: "days", value: String(days)) ]
                guard let url = components.url else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Network error when starting trial: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.network(error))) }
                        return
                    }
                    guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        logger.error("Invalid response when starting trial: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.invalidResponse)) }
                        return
                    }
                    do {
                        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                        logger.info("Successfully started trial for \(days) days")
                        DispatchQueue.main.async { completion(.success(authResponse)) }
                    } catch {
                        logger.error("Decoding error when starting trial: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.decoding(error))) }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Check subscription
    
    /// Checks the current subscription status of the user.
    /// - Parameter completion: Result with `SubscriptionResponse` or `Error`.
    internal func checkSubscription(completion: @escaping (Result<SubscriptionResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/subscription/me") else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Network error when checking subscription: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.network(error))) }
                        return
                    }
                    guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        logger.error("Invalid response when checking subscription: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.invalidResponse)) }
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let subscriptionStatus = try decoder.decode(SubscriptionResponse.self, from: data)
                        logger.info("Successfully fetched subscription status")
                        DispatchQueue.main.async { completion(.success(subscriptionStatus)) }
                    } catch {
                        logger.error("Decoding error when checking subscription: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.decoding(error))) }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Grant PRO
    
    /// Grants PRO plan until a specific moment.
    /// - Parameters:
    ///   - plan: Plan identifier (e.g., "PRO")
    ///   - validUntil: ISO8601 date-time string when license expires
    ///   - completion: Result with `AuthResponse` or `Error`
    internal func grantPro(plan: String, validUntil: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                var components = URLComponents(string: "https://banana.avoqode.com/api/v1/subscription/grant-pro")!
                components.queryItems = [
                    URLQueryItem(name: "plan", value: plan),
                    URLQueryItem(name: "validUntil", value: validUntil)
                ]
                guard let url = components.url else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Network error when granting PRO: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.network(error))) }
                        return
                    }
                    guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        logger.error("Invalid response when granting PRO: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.invalidResponse)) }
                        return
                    }
                    do {
                        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                        logger.info("Successfully granted PRO plan: \(plan) until \(validUntil)")
                        DispatchQueue.main.async { completion(.success(authResponse)) }
                    } catch {
                        logger.error("Decoding error when granting PRO: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.decoding(error))) }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
