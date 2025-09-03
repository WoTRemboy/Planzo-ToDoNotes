import Foundation
import OSLog

private let logger = Logger(subsystem: "com.todonotes.opening", category: "AuthNetworkService")

final class AuthNetworkService: ObservableObject {
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
                logger.info("Google authorization succeeded, access token received.")
                DispatchQueue.main.async {
                    completion(.success(authResponse))
                }
            } catch {
                logger.error("Failed to decode Google authorization response: \(error.localizedDescription)")
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
