//
//  SubscriptionViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.todonotes.subscription", category: "SubscriptionViewModel")

final class SubscriptionViewModel: ObservableObject {
    
    @Published internal var selectedFreePlan: Bool = false
    @Published internal var selectedSubscriptionPlan: SubscriptionPlan = .annual
    
    @Published internal var showingErrorAlert: Bool = false
    
    private(set) var steps = SubscriptionCarousel.stepsSetup()
    
    internal var pages: [Int] {
        Array(0..<steps.count)
    }
    
    internal func changePlan(_ plan: SubscriptionPlan) {
        withAnimation(.easeInOut(duration: 0.1)) {
            selectedSubscriptionPlan = plan
        }
    }
    
    internal func isSelectedPlan(_ plan: SubscriptionPlan) -> Bool {
        plan == selectedSubscriptionPlan
    }
    
    internal func strokeColor(for plan: SubscriptionPlan) -> Color {
        plan == selectedSubscriptionPlan ? .supportSubscription : .labelSecondary
    }
    
    internal func toggleShowingErrorAlert() {
        showingErrorAlert.toggle()
    }
    
    internal func openSupportLink(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    internal func handleGoogleSignIn(googleAuthService: GoogleAuthService) {
        guard let topVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) })
            .first?.rootViewController else {
            logger.error("Top view controller not found for Google Sign-In presentation.")
            return
        }
        
        googleAuthService.signInWithGoogle(presentingViewController: topVC) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.showingErrorAlert = true
                    logger.error("Google Sign-In failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    internal func handleAppleSignIn(appleAuthService: AppleAuthService) {
        LoadingOverlay.shared.show()
        
        appleAuthService.onBackendAuthResult = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                LoadingOverlay.shared.hide()
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.showingErrorAlert = true
                    logger.error("Apple Sign-In backend failed: \(error.localizedDescription)")
                }
            }
        }
        appleAuthService.onAuthError = { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                LoadingOverlay.shared.hide()
                self.showingErrorAlert = true
                logger.error("Apple Sign-In failed: \(error.localizedDescription)")
            }
        }
        appleAuthService.startAppleSignIn()
    }
}
