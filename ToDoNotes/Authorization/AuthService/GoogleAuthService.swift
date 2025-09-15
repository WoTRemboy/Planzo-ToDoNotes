//
//  GoogleAuthService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 03/09/2025.
//

import GoogleSignIn
import OSLog
import UIKit

private let logger = Logger(subsystem: "com.todonotes.opening", category: "GoogleAuthService")

final class GoogleAuthService: ObservableObject {
    private let clientID: String
    private let networkService: AuthNetworkService
    
    init(networkService: AuthNetworkService) {
        self.networkService = networkService
        
        if let clientID = ProcessInfo.processInfo.environment["GOOGLE_CLIENT_ID"], !clientID.isEmpty {
            self.clientID = clientID
        } else {
            self.clientID = Secrets.googleClientID
        }
    }
    
    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            if let error = error {
                logger.error("Google Sign-In failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let signInResult = signInResult else { return }
            signInResult.user.refreshTokensIfNeeded { user, error in
                if let error {
                    logger.error("Google Refresh Token: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                guard let user = user,
                      let idToken = user.idToken?.tokenString
                else {
                    logger.error("Google Sign-In: idToken not found")
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }
                self.networkService.googleAuthorize(idToken: idToken, completion: completion)
            }
        }
    }
}
