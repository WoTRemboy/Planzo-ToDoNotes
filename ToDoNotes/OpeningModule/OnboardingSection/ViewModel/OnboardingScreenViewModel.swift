//
//  OnboardingScreenViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import Foundation
import SwiftUI
import AuthenticationServices

/// ViewModel responsible for managing the state and actions in the onboarding process.
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Properties
    
    /// A flag stored in `AppStorage` to track if this is the first launch of the app.
//    @AppStorage(Texts.UserDefaults.skipOnboarding) var skipOnboarding: Bool = false
    @Published internal var skipOnboarding: Bool = false
    /// The list of onboarding steps, initialized using `stepsSetup()`.
    @Published internal var steps = OnboardingStep.stepsSetup()
    /// Tracks the index of the current onboarding step.
    @Published internal var currentStep = 0
    
    // MARK: - Computed Properties
    
    /// The total number of steps in the onboarding process.
    internal var stepsCount: Int {
        steps.count
    }
    
    /// Determines the type of button to display (either `.nextPage` or `.getStarted`) based on the current step.
    internal var buttonType: OnboardingButtonType {
        if currentStep < steps.count - 1 {
            return .nextPage
        } else {
            return .getStarted
        }
    }
    
    // MARK: - Methods
    
    /// Advances to the next onboarding step with a smooth animation or sets `firstLaunch` to `true`, marking the onboarding as complete..
    internal func nextStep() {
        withAnimation(.easeInOut) {
            switch buttonType {
            case .nextPage:
                currentStep += 1
            case .getStarted:
                skipOnboarding = true
            }
        }
    }
    
    /// Skips directly to the final onboarding step with a smooth animation.
    internal func skipSteps() {
        withAnimation(.easeInOut) {
            switch buttonType {
            case .nextPage:
                currentStep = steps.count - 1
            case .getStarted:
                skipOnboarding.toggle()
            }
        }
    }
    
    internal func authorization(result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let auth):
            switch auth.credential {
            case let credential as ASAuthorizationAppleIDCredential:
                let token = credential.authorizationCode
                nextStep()
                print(token ?? String())
                break
            default:
                break
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
