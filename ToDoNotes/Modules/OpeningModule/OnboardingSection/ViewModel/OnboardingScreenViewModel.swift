//
//  OnboardingScreenViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import Foundation
import SwiftUI

/// ViewModel responsible for managing the state and actions in the onboarding process.
final class OnboardingViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    /// A flag indicating if onboarding should be skipped (i.e., onboarding is completed).
    @AppStorage(Texts.UserDefaults.skipOnboarding) var skipOnboarding: Bool = false
    /// A flag controlling the glow effect around the "Add Task" button after onboarding.
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow) private var addTaskButtonGlow: Bool = false
    
    /// The list of onboarding steps, initialized using `stepsSetup()`.
    private(set) var steps = OnboardingStep.stepsSetup()
    
    // MARK: - Computed Properties
    
    /// Pages for the onboarding process.
    internal var pages: [Int] {
        Array(0..<steps.count)
    }
    
    // MARK: - Methods
    
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
}
