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
    
    /// Small delay before performing logout after refresh (in seconds).
    private let logoutDelay: TimeInterval = 1.5
    
    func googleAuthorize(idToken: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
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
        print(idToken)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                logger.error("Google authorization request failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            print(String(data: data!, encoding: .utf8)!)
            guard let data = data else {
                logger.error("Google authorization response data is nil.")
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                logger.info("Google authorization succeeded, access token received.")
                // Return result to caller as before
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
    
    func appleAuthorize(idToken: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
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
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
                if let dataString = String(data: data, encoding: .utf8) {
                    print(dataString)
                }
                
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                logger.info("Apple authorization succeeded, access token received.")
                // Return result to caller as before
                DispatchQueue.main.async {
                    completion(.success(authResponse))
                }
                // Chain: refresh -> delay -> logout
                self?.refreshThenLogout(after: authResponse)
            } catch {
                logger.error("Failed to decode Apple authorization response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func refreshTokens(refreshToken: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
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
    
    func logout(accessToken: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
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
            logger.info("Logout request succeeded.")
            completion?(.success(()))
        }
        task.resume()
    }
}

// MARK: - Private helpers
private extension AuthNetworkService {
    /// Performs refresh with the given authResponse, then after a small delay logs out.
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
}
