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
        let plan: String?
        /// The current status of the license
        let status: String
        let trialUsed: Bool
    }
    
//    let trialAvailable: Bool
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
                guard let base = NetworkConfig.url("/api/v1/subscription/trial") else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var components = URLComponents(url: base, resolvingAgainstBaseURL: false)!
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
                guard let url = NetworkConfig.url("/api/v1/subscription/me") else {
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

    // MARK: - Check subscription
    
    /// Checks the current subscription status of the user with additional fields from DB.
    /// - Parameter completion: Result with `SubscriptionResponse` or `Error`.
    internal func checkSubscriptionFull(completion: @escaping (Result<SubscriptionResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = NetworkConfig.url("/api/v1/subscription/me/full") else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Network error when checking subscription (full): \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.network(error))) }
                        return
                    }
                    guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        logger.error("Invalid response when checking subscription (full): \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.invalidResponse)) }
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let subscriptionStatus = try decoder.decode(SubscriptionResponse.self, from: data)
                        logger.info("Successfully fetched full subscription status")
                        DispatchQueue.main.async { completion(.success(subscriptionStatus)) }
                    } catch {
                        logger.error("Decoding error when checking subscription (full): \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.decoding(error))) }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Apple subscription attach
    
    /// Attaches an Apple subscription by StoreKit transaction identifier.
    /// - Parameters:
    ///   - transactionId: The StoreKit transaction identifier string.
    ///   - completion: Result with `AuthResponse` or `Error`.
    internal func attachAppleSubscription(transactionId: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let base = NetworkConfig.url("/api/v1/subscription/apple/attach") else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var components = URLComponents(url: base, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "transactionId", value: transactionId)
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
                        logger.error("Network error when attaching Apple subscription: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.network(error))) }
                        return
                    }
                    guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        logger.error("Invalid response when attaching Apple subscription: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.invalidResponse)) }
                        return
                    }
                    do {
                        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                        logger.info("Successfully attached Apple subscription by transactionId")
                        DispatchQueue.main.async { completion(.success(authResponse)) }
                    } catch {
                        logger.error("Decoding error when attaching Apple subscription: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.decoding(error))) }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Apple subscription refresh
    
    /// Forces refresh of the Apple subscription state using saved transaction identifiers.
    /// - Parameter completion: Result with `AuthResponse` or `Error`.
    internal func refreshAppleSubscription(completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = NetworkConfig.url("/api/v1/subscription/apple/refresh") else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Network error when refreshing Apple subscription: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.network(error))) }
                        return
                    }
                    
                    guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        logger.error("Invalid response when refreshing Apple subscription: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.invalidResponse)) }
                        return
                    }
                    do {
                        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                        logger.info("Successfully refreshed Apple subscription state")
                        DispatchQueue.main.async { completion(.success(authResponse)) }
                    } catch {
                        logger.error("Decoding error when refreshing Apple subscription: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.decoding(error))) }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Dev: Reset license
        
    /// DEV ONLY: Resets license and Apple subscription state on the server.
    /// - Parameter completion: Result with `AuthResponse` or `Error`.
    internal func resetLicenseDev(completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = NetworkConfig.url("/api/v1/subscription/dev/reset-license") else {
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Network error when resetting license (dev): \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.network(error))) }
                        return
                    }
                    guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        logger.error("Invalid response when resetting license (dev): \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                        DispatchQueue.main.async { completion(.failure(SubscriptionAPIError.invalidResponse)) }
                        return
                    }
                    do {
                        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                        logger.info("Successfully reset license (dev)")
                        DispatchQueue.main.async { completion(.success(authResponse)) }
                    } catch {
                        logger.error("Decoding error when resetting license (dev): \(error.localizedDescription)")
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
