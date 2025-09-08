//
//  AuthNetworkService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 03/09/2025.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.todonotes.opening", category: "AuthNetworkService")

final class AuthNetworkService: ObservableObject {
    
    @Published var currentUser: User? = nil
    @Published var accessToken: String? = nil
    @Published var refreshToken: String? = nil

    // Keys for storing to UserDefaults
    private let userKey = "CurrentUserProfile"
    private let accessTokenKey = "AccessToken"
    private let refreshTokenKey = "RefreshToken"
    
    private let logoutDelay: TimeInterval = 1.5
    
    internal func googleAuthorize(idToken: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "https://banana.avoqode.com/api/v1/auth/google") else {
            logger.error("Invalid Google authorization URL.")
            DispatchQueue.main.async {
                completion(.failure(URLError(.badURL)))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["idToken": idToken]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            logger.error("Failed to encode idToken in JSON body: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                logger.error("Google authorization request failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let data = data else {
                logger.error("Google authorization response data is nil.")
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.saveAuthResponse(authResponse, idToken: idToken)
                logger.info("Google authorization succeeded, access token received.")
                DispatchQueue.main.async {
                    completion(.success(authResponse))
                }
//                self?.refreshThenLogout(after: authResponse)
            } catch {
                logger.error("Failed to decode Google authorization response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    internal func appleAuthorize(idToken: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "https://banana.avoqode.com/api/v1/auth/apple") else {
            logger.error("Invalid Apple authorization URL.")
            DispatchQueue.main.async {
                completion(.failure(URLError(.badURL)))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["idToken": idToken]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            logger.error("Failed to encode idToken in JSON body: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                logger.error("Apple authorization request failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let data = data else {
                logger.error("Apple authorization response data is nil.")
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.saveAuthResponse(authResponse, idToken: idToken)
                logger.info("Apple authorization succeeded, access token received.")
                DispatchQueue.main.async {
                    completion(.success(authResponse))
                }
                // self?.refreshThenLogout(after: authResponse)
            } catch {
                logger.error("Failed to decode Apple authorization response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    internal func refreshTokens(refreshToken: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "https://banana.avoqode.com/api/v1/auth/refresh") else {
            logger.error("Invalid refresh token endpoint URL.")
            DispatchQueue.main.async {
                completion(.failure(URLError(.badURL)))
            }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["refreshToken": refreshToken]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            logger.error("Failed to encode refreshToken in JSON body: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                logger.error("Token refresh request failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let data = data else {
                logger.error("Token refresh response data is nil.")
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.saveAuthResponse(authResponse)
                logger.info("Token refresh succeeded, access token received.")
                DispatchQueue.main.async {
                    completion(.success(authResponse))
                }
            } catch {
                logger.error("Failed to decode token refresh response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    internal func logout(accessToken: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = URL(string: "https://banana.avoqode.com/api/v1/auth/logout") else {
            logger.error("Invalid logout endpoint URL.")
            completion?(.failure(URLError(.badURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let body: [String: Bool] = ["allDevices": true]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            logger.error("Failed to encode logout body: \(error.localizedDescription)")
            completion?(.failure(error))
            return
        }
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                logger.error("Logout failed: \(error.localizedDescription)")
                completion?(.failure(error))
                return
            }
            self.clearProfile()
            logger.info("Logout request succeeded.")
            completion?(.success(()))
        }
        task.resume()
    }
    
    func loadPersistedProfile() {
        if let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            logger.debug("Current user loaded from cache.")
        }
        self.accessToken = UserDefaults.standard.string(forKey: accessTokenKey)
        self.refreshToken = UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    var isAuthorized: Bool {
        accessToken != nil && currentUser != nil
    }
    
    private func saveAuthResponse(_ authResponse: AuthResponse, idToken: String? = nil) {
        if let idToken = idToken,
           let claims = decodeJWTClaims(from: idToken) {
            let user = User(
                id: authResponse.user.id,
                provider: authResponse.user.provider,
                sub: authResponse.user.sub,
                createdAt: authResponse.user.createdAt,
                name: (claims["name"] as? String) ?? (claims["given_name"] as? String),
                email: claims["email"] as? String,
                avatarUrl: claims["picture"] as? String
            )
            logger.debug("Current user saved to cache.")
            DispatchQueue.main.async {
                self.currentUser = user
                if let encodedUser = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encodedUser, forKey: self.userKey)
                }
                self.accessToken = authResponse.accessToken
                self.refreshToken = authResponse.refreshToken
                UserDefaults.standard.set(authResponse.accessToken, forKey: self.accessTokenKey)
                UserDefaults.standard.set(authResponse.refreshToken, forKey: self.refreshTokenKey)
            }
        } else {
            DispatchQueue.main.async {
                self.currentUser = authResponse.user
                if let encodedUser = try? JSONEncoder().encode(authResponse.user) {
                    UserDefaults.standard.set(encodedUser, forKey: self.userKey)
                }
                self.accessToken = authResponse.accessToken
                self.refreshToken = authResponse.refreshToken
                UserDefaults.standard.set(authResponse.accessToken, forKey: self.accessTokenKey)
                UserDefaults.standard.set(authResponse.refreshToken, forKey: self.refreshTokenKey)
            }
        }
    }
    
    private func clearProfile() {
        DispatchQueue.main.async {
            self.currentUser = nil
            self.accessToken = nil
            self.refreshToken = nil
            UserDefaults.standard.removeObject(forKey: self.userKey)
            UserDefaults.standard.removeObject(forKey: self.accessTokenKey)
            UserDefaults.standard.removeObject(forKey: self.refreshTokenKey)
        }
    }
}

// MARK: - Private helpers

private extension AuthNetworkService {
    func refreshThenLogout(after authResponse: AuthResponse) {
        let initialAccessToken = authResponse.accessToken
        let refreshToken = authResponse.refreshToken
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (self.logoutDelay)) {
            logger.debug("Starting refresh after authorization...")
            self.refreshTokens(refreshToken: refreshToken) { [weak self] result in
                switch result {
                case .success(let refreshed):
                    logger.info("Refresh succeeded. Scheduling logout after \(self?.logoutDelay ?? 0) seconds.")
                    let accessForLogout = refreshed.accessToken
                    DispatchQueue.main.asyncAfter(deadline: .now() + (self?.logoutDelay ?? 0)) {
                        self?.logout(accessToken: accessForLogout, completion: nil)
                    }
                case .failure(let error):
                    logger.error("Refresh failed: \(error.localizedDescription). Proceeding to logout with initial access token after delay.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + (self?.logoutDelay ?? 0)) { [weak self] in
                        self?.logout(accessToken: initialAccessToken, completion: nil)
                    }
                }
            }
        }
    }
    
    func decodeJWTClaims(from idToken: String) -> [String: Any]? {
        let segments = idToken.split(separator: ".")
        guard segments.count > 1,
              let payloadData = Data(base64Encoded: String(segments[1])
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
                .padding(toLength: ((String(segments[1]).count+3)/4)*4, withPad: "=", startingAt: 0)) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: payloadData, options: [])) as? [String: Any]
    }
}

