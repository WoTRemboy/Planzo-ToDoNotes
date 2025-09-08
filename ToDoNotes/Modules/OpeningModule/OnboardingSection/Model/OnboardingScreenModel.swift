//
//  OnboardingScreenModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI

// MARK: - Onboarding Step Model

/// Represents a step in the onboarding process, including title, description, and image.
struct OnboardingStep {
    /// Title of the onboarding step.
    let name: String
    /// Description of what this step covers.
    let description: String
    /// Image associated with this onboarding step.
    let image: Image
}

// MARK: - Onboarding Step Setup

extension OnboardingStep {
    
    /// Configures and returns the list of onboarding steps.
    /// - Returns: An array of `OnboardingStep` instances, each representing a step in the onboarding process.
    static func stepsSetup() -> [OnboardingStep] {
        let first = OnboardingStep(name: Texts.OnboardingPage.firstTitle,
                                   description: Texts.OnboardingPage.placeholderContent,
                                   image: .Onboarding.first)
        
        let second = OnboardingStep(name: Texts.OnboardingPage.secondTitle,
                                    description: Texts.OnboardingPage.placeholderContent,
                                    image: .Onboarding.second)
        
        let third = OnboardingStep(name: Texts.OnboardingPage.thirdTitle,
                                   description: Texts.OnboardingPage.placeholderContent,
                                   image: .Onboarding.third)
        
        let fourth = OnboardingStep(name: Texts.OnboardingPage.fourthTitle,
                                    description: Texts.OnboardingPage.placeholderContent,
                                    image: .Onboarding.fourth)
        
        return [first, second, third, fourth]
    }
}

// MARK: - Onboarding Button Type

/// Enum defining types of buttons in the onboarding screen.
enum OnboardingButtonType {
    /// Button that navigates to the next onboarding step.
    case nextPage
    /// Button that completes onboarding and starts the app.
    case getStarted
}

// MARK: - Identifiable Error Type

struct IdentifiableError: Identifiable, Error {
    let id = UUID()
    let wrapped: Error
    var localizedDescription: String { wrapped.localizedDescription }
}
