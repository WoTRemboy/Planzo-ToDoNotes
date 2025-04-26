//
//  AuthorizationViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/12/25.
//

import AuthenticationServices
import GoogleSignIn
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "AuthorizationViewModel", category: "OpeningModule")

/// Extension for `OnboardingViewModel` that handles user authentication via Google Sign-In and Apple ID.
extension OnboardingViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - Google Authorization
    
    /// Initiates Google Sign-In authentication flow.
    internal func googleAuthorization() {
        if let rootViewController = RootViewControllerMethods.getRootViewController() {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            ) { signInResult, error in
                guard let signInResult else {
                    logger.error("Google sign-in failed: \(error?.localizedDescription ?? "No error description")")
                    return
                }
                logger.info("UserID: \(signInResult.user.userID ?? "error userID", privacy: .sensitive)")
                logger.info("Email: \(signInResult.user.profile?.email ?? "error email", privacy: .sensitive)")
            }
        }
    }
    
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
            logger.info("Token: \(token?.base64EncodedString() ?? "error token", privacy: .sensitive)")
            transferToMainPage()
        }
    }

    /// Handles Apple Sign-In authorization failure.
    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        logger.error("Apple authorization failed with error: \(error.localizedDescription)")
    }
    
    /// Provides the window (presentation anchor) where the Apple authorization UI should be displayed.
    internal func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            return windowScene.windows.first { $0.isKeyWindow } ?? UIWindow()
        }
        return UIWindow()
    }
}
