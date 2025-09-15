//
//  OnboardingScreenViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import Foundation
import SwiftUI
import OSLog
import UIKit

/// ViewModel responsible for managing the state and actions in the onboarding process.
final class OnboardingViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ToDoNotes", category: "OnboardingViewModel")

    /// A flag indicating if onboarding should be skipped (i.e., onboarding is completed).
    @AppStorage(Texts.UserDefaults.skipOnboarding) var skipOnboarding: Bool = false
    /// A flag controlling the glow effect around the "Add Task" button after onboarding.
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow) private var addTaskButtonGlow: Bool = false
    
    /// The list of onboarding steps, initialized using `stepsSetup()`.
    private(set) var steps = OnboardingStep.stepsSetup()
    
    /// Stores an error to be displayed in alerts.
    @Published internal var alertError: IdentifiableError?
    @Published internal var showingErrorAlert: Bool = false
    @Published internal var isAuthorizing: Bool = false
    
    // MARK: - Computed Properties
    
    /// Pages for the onboarding process.
    internal var pages: [Int] {
        Array(0..<steps.count)
    }
    
    // MARK: - Methods
    
    internal func toggleShowingErrorAlert() {
        showingErrorAlert.toggle()
    }
    
    internal func toggleShowingIsAuthorizing(to value: Bool) {
        withAnimation(.easeInOut(duration: 0.2)) {
            isAuthorizing = value
        }
    }
    
    /// Determines if the given page index corresponds to the last onboarding page.
    /// - Parameter current: The current page index.
    /// - Returns: `true` if the current page is the last; otherwise, `false`.
    internal func isLastPage(current: Int) -> Bool {
        current == steps.count - 1
    }
    
    /// Skips directly to the final onboarding step with a smooth animation.
    internal func transferToMainPage() {
        withAnimation(.easeInOut) {
            skipOnboarding.toggle()
            addTaskButtonGlow.toggle()
        }
    }
    
    internal func signInWithGoogle(googleAuthService: GoogleAuthService, presentingViewController: UIViewController, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        googleAuthService.signInWithGoogle(presentingViewController: presentingViewController, completion: completion)
    }
    
    func handleGoogleSignIn(googleAuthService: GoogleAuthService) {
        guard let topVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) })
            .first?.rootViewController else {
            logger.error("Top view controller not found for Google Sign-In presentation.")
            return
        }
        toggleShowingIsAuthorizing(to: true)
        googleAuthService.signInWithGoogle(presentingViewController: topVC) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.toggleShowingIsAuthorizing(to: false)
                switch result {
                case .success:
                    self.transferToMainPage()
                case .failure(let error):
                    self.alertError = IdentifiableError(wrapped: error)
                    self.showingErrorAlert = true
                }
            }
        }
    }
    
    internal func handleAppleSignIn(appleAuthService: AppleAuthService) {
        toggleShowingIsAuthorizing(to: true)
        appleAuthService.onBackendAuthResult = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.toggleShowingIsAuthorizing(to: false)
                
                switch result {
                case .success:
                    self.transferToMainPage()
                case .failure(let error):
                    self.alertError = IdentifiableError(wrapped: error)
                    self.showingErrorAlert = true
                    self.logger.error("Apple Sign-In backend failed: \(error.localizedDescription)")
                }
            }
        }
        appleAuthService.onAuthError = { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.toggleShowingIsAuthorizing(to: false)
                self.showingErrorAlert = true
                self.logger.error("Apple Sign-In failed: \(error.localizedDescription)")
            }
        }
        appleAuthService.startAppleSignIn()
    }
}

