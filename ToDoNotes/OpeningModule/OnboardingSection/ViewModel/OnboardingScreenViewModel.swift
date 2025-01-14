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
    
    /// A flag stored in `AppStorage` to track if this is the first launch of the app.
    @AppStorage(Texts.UserDefaults.skipOnboarding) var skipOnboarding: Bool = false
//    @Published private(set) var skipOnboarding: Bool = false
    /// The list of onboarding steps, initialized using `stepsSetup()`.
    private(set) var steps = OnboardingStep.stepsSetup()
    
    // MARK: - Computed Properties
    
    /// Pages for the onboarding process.
    internal var pages: [Int] {
        Array(0..<steps.count)
    }
    
    // MARK: - Methods
    
    internal func isLastPage(current: Int) -> Bool {
        current == steps.count - 1
    }
    
    /// Skips directly to the final onboarding step with a smooth animation.
    internal func transferToMainPage() {
        withAnimation(.easeInOut) {
            skipOnboarding.toggle()
        }
    }
}
