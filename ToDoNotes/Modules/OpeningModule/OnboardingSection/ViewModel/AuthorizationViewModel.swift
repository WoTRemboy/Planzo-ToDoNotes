//
//  AuthorizationViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/12/25.
//  Реализует Google Sign-In через SDK и OAuth Web как fallback.
//

import AuthenticationServices
import OSLog
import GoogleSignIn

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.opening", category: "AuthorizationViewModel")

/// Extension for `OnboardingViewModel` that handles user authentication via Google Sign-In and Apple ID.
extension OnboardingViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, ASWebAuthenticationPresentationContextProviding {
    
    // MARK: - Apple Authorization
    
    /// Starts the Apple Sign-In authentication flow.
    internal func startAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    /// Handles successful Apple Sign-In authorization.
    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let token = appleIDCredential.authorizationCode
            logger.info("Token: \(token?.base64EncodedString() ?? "error token", privacy: .sensitive).")
            transferToMainPage()
        }
    }

    /// Handles Apple Sign-In authorization failure.
    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        logger.error("Apple authorization failed with error: \(error.localizedDescription).")
    }
    
    /// Provides the window (presentation anchor) where the Apple authorization UI should be displayed.
    internal func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            return windowScene.windows.first { $0.isKeyWindow } ?? UIWindow()
        }
        return UIWindow()
    }
    
    /// Provides the window (presentation anchor) for ASWebAuthenticationSession.
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            return windowScene.windows.first { $0.isKeyWindow } ?? UIWindow()
        }
        return UIWindow()
    }
    
    // MARK: - Google Authorization
    
    /// Starts Google Sign-In using GoogleSignIn SDK
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let clientID = ""
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            if let error = error {
                logger.error("Google Sign-In failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
//            guard let user = signInResult?.user,
//                  let idToken = user.idToken?.tokenString else {
//                logger.error("Google Sign-In: idToken not found")
//                completion(.failure(URLError(.badServerResponse)))
//                return
//            }
            guard let signInResult = signInResult else { return }
            
            signInResult.user.refreshTokensIfNeeded { user, error in
                guard error == nil else { return }
                guard let user = user else { return }
                
                let idToken = user.idToken?.tokenString ?? ""
                // Send idToken to server
                self.googleAuthorize(idToken: idToken, completion: completion)
            }
        }
    }
    
    /// Represents the user information returned by the Google authorization response.
    internal struct User: Codable {
        let id: String
        let provider: String
        let sub: String
        let createdAt: String
    }
    
    /// Represents the structure of the response returned by the Google authorization endpoint.
    internal struct AuthResponse: Codable {
        let accessToken: String
        let accessTokenExpiresAt: String
        let refreshToken: String
        let refreshTokenExpiresAt: String
        let tokenType: String
        let user: User
        
        private enum CodingKeys: String, CodingKey {
            case accessToken = "accessToken"
            case accessTokenExpiresAt = "accessTokenExpiresAt"
            case refreshToken = "refreshToken"
            case refreshTokenExpiresAt = "refreshTokenExpiresAt"
            case tokenType = "tokenType"
            case user
        }
    }
    
    /// Sends a POST request to authenticate the user with Google using the provided ID token.
    /// - Parameters:
    ///   - idToken: The ID token obtained from Google Sign-In.
    ///   - completion: Completion handler called with the result of the authentication request.
    internal func googleAuthorize(idToken: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        guard let url = URL(string: "https://banana.avoqode.com/api/v1/auth/google") else {
            logger.error("Invalid Google authorization URL.")
            DispatchQueue.main.async {
                completion(.failure(URLError(.badURL)))
            }
            return
        }
        print(idToken)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["idToken": idToken]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            if let body = request.httpBody, let text = String(data: body, encoding: .utf8) {
                print("Body: \(text)")
            }
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
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                print(data)
                if let text = String(data: data, encoding: .utf8) {
                    logger.error("Server answer: \(text)")
                }
                let authResponse = try decoder.decode(AuthResponse.self, from: data)
                
                logger.info("Google authorization succeeded, access token received.")
                DispatchQueue.main.async {
                    logger.info("Token is: \(authResponse.accessToken)")
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
    
    /// Requests new access and refresh tokens using a refresh token.
    /// - Parameters:
    ///   - refreshToken: The refresh token string.
    ///   - completion: Completion handler called with the result of the authentication request.
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
            if let body = request.httpBody, let text = String(data: body, encoding: .utf8) {
                print("Refresh Body: \(text)")
            }
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
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                if let text = String(data: data, encoding: .utf8) {
                    logger.error("Refresh server answer: \(text)")
                }
                let authResponse = try decoder.decode(AuthResponse.self, from: data)
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
    
    /// Logs out the user by invalidating the token on the server.
    /// - Parameters:
    ///   - accessToken: The access token to invalidate.
    ///   - completion: Called when the logout request completes.
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
            logger.info("Logout request succeeded.")
            completion?(.success(()))
        }
        task.resume()
    }
}
