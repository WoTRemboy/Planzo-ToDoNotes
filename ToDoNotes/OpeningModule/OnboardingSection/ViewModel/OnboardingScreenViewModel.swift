//
//  OnboardingScreenViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import Foundation
import SwiftUI

/// ViewModel responsible for managing the state and actions in the onboarding process.
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Properties
    
    /// A flag stored in `AppStorage` to track if this is the first launch of the app.
    @AppStorage(Texts.UserDefaults.skipOnboarding) var skipOnboarding: Bool = false
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
    
    /// Advances to the next onboarding step with a smooth animation.
    internal func nextStep() {
        withAnimation(.easeInOut) {
            currentStep += 1
        }
    }
    
    /// Skips directly to the final onboarding step with a smooth animation.
    internal func skipSteps() {
        withAnimation(.easeInOut) {
            currentStep = steps.count - 1
        }
    }
    
    /// Sets `firstLaunch` to `true`, marking the onboarding as complete.
    internal func getStarted() {
        withAnimation {
            skipOnboarding = true
        }
    }
}
