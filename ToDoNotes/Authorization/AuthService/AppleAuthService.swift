//
//  AppleAuthService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 03/09/2025.
//

import AuthenticationServices
import OSLog
import UIKit

private let logger = Logger(subsystem: "com.todonotes.opening", category: "AppleAuthService")

final class AppleAuthService: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, ASWebAuthenticationPresentationContextProviding {
    
    internal var onAuthSuccess: ((ASAuthorizationAppleIDCredential) -> Void)?
    internal var onAuthError: ((Error) -> Void)?
    internal var onBackendAuthResult: ((Result<AuthResponse, Error>) -> Void)?
    
    private let networkService: AuthNetworkService
    
    init(networkService: AuthNetworkService = AuthNetworkService()) {
        self.networkService = networkService
        super.init()
    }

    internal func startAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - ASAuthorizationControllerDelegate
    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            logger.error("Apple authorization finished, but credential is not ASAuthorizationAppleIDCredential.")
            onAuthError?(URLError(.cannotParseResponse))
            return
        }
        
//        let userName: String?
//        if let fullName = appleIDCredential.fullName {
//            userName = (fullName.givenName ?? "") + (fullName.familyName ?? "")
//            logger.info("Apple user full name: \(userName ?? String())")
//        } else {
//            userName = nil
//            logger.info("Apple user fullName is nil")
//        }
        
        logger.info("Apple sign-in succeeded.")
        onAuthSuccess?(appleIDCredential)
        
        guard let tokenData = appleIDCredential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8),
              !idToken.isEmpty
        else {
            logger.error("Apple identityToken is missing or cannot be decoded.")
            onAuthError?(URLError(.badServerResponse))
            return
        }
                
        logger.debug("Apple idToken received. Exchanging with backend...")
        networkService.appleAuthorize(idToken: idToken) { [weak self] result in
            switch result {
            case .success(let authResponse):
                logger.info("Backend Apple authorization succeeded.")
                self?.onBackendAuthResult?(.success(authResponse))
            case .failure(let error):
                logger.error("Backend Apple authorization failed: \(error.localizedDescription)")
                self?.onBackendAuthResult?(.failure(error))
                self?.onAuthError?(error)
            }
        }
    }
    
    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        logger.error("Apple authorization failed with error: \(error.localizedDescription).")
        onAuthError?(error)
    }
    
    // MARK: - Presentation
    
    internal func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            return windowScene.windows.first { $0.isKeyWindow } ?? UIWindow()
        }
        return UIWindow()
    }
    
    internal func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            return windowScene.windows.first { $0.isKeyWindow } ?? UIWindow()
        }
        return UIWindow()
    }
}
