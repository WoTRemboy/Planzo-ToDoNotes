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

    // Keys for storing to UserDefaults
    private let userKey = "CurrentUserProfile"
    
    private let logoutDelay: TimeInterval = 1.5
    private let tokenStorage = TokenStorageService()
    
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
        LoadingOverlay.shared.show()
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
                    ListNetworkService.shared.syncAllBackTasks()
                    completion(.success(authResponse))
                }
                LoadingOverlay.shared.hide()
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
                    ListNetworkService.shared.syncAllBackTasks()
                    completion(.success(authResponse))
                }
            } catch {
                logger.error("Failed to decode Apple authorization response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    internal func refreshTokens(completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "https://banana.avoqode.com/api/v1/auth/refresh") else {
            logger.error("Invalid refresh token endpoint URL.")
            DispatchQueue.main.async {
                completion(.failure(URLError(.badURL)))
            }
            return
        }
        guard let refreshToken = tokenStorage.load(type: .refreshToken) else {
            logger.error("No refresh token to refresh with.")
            completion(.failure(URLError(.userAuthenticationRequired)))
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
    
    internal func logout(completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = URL(string: "https://banana.avoqode.com/api/v1/auth/logout") else {
            logger.error("Invalid logout endpoint URL.")
            completion?(.failure(URLError(.badURL)))
            return
        }
        guard let accessToken = tokenStorage.load(type: .accessToken) else {
            logger.error("No access token to logout.")
            completion?(.failure(URLError(.userAuthenticationRequired)))
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
    }
    
    var isAuthorized: Bool {
        let accessToken = tokenStorage.load(type: .accessToken)
        return accessToken != nil && currentUser != nil
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
                self.tokenStorage.save(token: authResponse.accessToken, type: .accessToken)
                self.tokenStorage.save(token: authResponse.refreshToken, type: .refreshToken)
            }
        } else {
            DispatchQueue.main.async {
                self.currentUser = authResponse.user
                if let encodedUser = try? JSONEncoder().encode(authResponse.user) {
                    UserDefaults.standard.set(encodedUser, forKey: self.userKey)
                }
                self.tokenStorage.save(token: authResponse.accessToken, type: .accessToken)
                self.tokenStorage.save(token: authResponse.refreshToken, type: .refreshToken)
            }
        }
    }
    
    private func clearProfile() {
        DispatchQueue.main.async {
            self.currentUser = nil
            UserDefaults.standard.removeObject(forKey: self.userKey)
            self.tokenStorage.delete(type: .accessToken)
            self.tokenStorage.delete(type: .refreshToken)
            TaskService.deleteAllBackendTasks()
        }
    }
}

// MARK: - Private helpers

private extension AuthNetworkService {
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
