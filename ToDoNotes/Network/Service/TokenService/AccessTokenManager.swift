//  AccessTokenManager.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/09/2025.

import Foundation

/// A singleton manager for handling access token validation and refresh.
final class AccessTokenManager {
    
    static let shared = AccessTokenManager()
    private let tokenStorage = TokenStorageService()
    private init() {}

    /// Checks if the access token is expired based on stored expiry date.
    func isAccessTokenExpired() -> Bool {
        guard let expiryString = UserDefaults.standard.string(forKey: "AccessTokenExpiresAt") else { return true }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let expiryDate = formatter.date(from: expiryString) else {
            return true
        }
        return Date() >= expiryDate
    }

    /// Loads a valid access token, refreshing if needed. Calls completion with valid token or error.
    func getValidAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        let accessToken = tokenStorage.load(type: .accessToken)
        if !isAccessTokenExpired(), let token = accessToken {
            completion(.success(token))
        } else {
            AuthNetworkService().refreshTokens { result in
                switch result {
                case .success(let authResponse):
                    // Persist accessTokenExpiresAt in UserDefaults
                    UserDefaults.standard.setValue(authResponse.accessTokenExpiresAt, forKey: "AccessTokenExpiresAt")
                    if let token = self.tokenStorage.load(type: .accessToken) {
                        completion(.success(token))
                    } else {
                        completion(.failure(URLError(.userAuthenticationRequired)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
