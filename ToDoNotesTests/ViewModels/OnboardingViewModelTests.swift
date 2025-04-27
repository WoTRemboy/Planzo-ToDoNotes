//
//  OnboardingViewModelTests.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/04/2025.
//

import XCTest
@testable import ToDoNotes

// MARK: - OnboardingViewModelTests

/// Unit tests for `OnboardingViewModel`.
/// Tests onboarding progress management and transfer to the main app flow.
final class OnboardingViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: OnboardingViewModel!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        viewModel = OnboardingViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Onboarding Steps Tests
    
    /// Tests that the correct number of onboarding steps are loaded.
    func test_StepsSetup_ShouldReturnFourSteps() {
        XCTAssertEqual(viewModel.steps.count, 4, "There should be exactly four onboarding steps configured.")
    }
    
    /// Tests that `pages` array matches the number of onboarding steps.
    func test_Pages_ShouldMatchStepsCount() {
        XCTAssertEqual(viewModel.pages.count, viewModel.steps.count, "Pages count should match steps count.")
    }
    
    /// Tests that `isLastPage` correctly identifies the last page.
    func test_IsLastPage_ShouldReturnTrue_WhenAtLastStep() {
        let lastPageIndex = viewModel.steps.count - 1
        XCTAssertTrue(viewModel.isLastPage(current: lastPageIndex), "Should return true at the last page.")
        
        XCTAssertFalse(viewModel.isLastPage(current: 0), "Should return false at the first page.")
    }
}
