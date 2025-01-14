//
//  AuthorizationViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/12/25.
//

import AuthenticationServices
import GoogleSignIn

extension OnboardingViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    internal func googleAuthorization() {
        if let rootViewController = RootViewControllerMethods.getRootViewController() {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            ) { signInResult, error in
                guard let signInResult else { return }
                print(signInResult.user.userID ?? String())
                print(signInResult.user.profile?.email ?? String())
            }
        }
    }
    
    internal func startAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let token = appleIDCredential.authorizationCode
            print(token ?? String())
            transferToMainPage()
        }
    }

    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization failed with error: \(error.localizedDescription)")
    }
    
    internal func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            return windowScene.windows.first { $0.isKeyWindow } ?? UIWindow()
        }
        return UIWindow()
    }
}
