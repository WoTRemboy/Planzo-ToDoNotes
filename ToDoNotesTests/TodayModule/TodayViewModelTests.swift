//
//  TodayViewModelTests.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/04/2025.
//

import XCTest
@testable import ToDoNotes

/// Unit tests for `TodayViewModel` that cover toggling UI flags and managing task selection state.
final class TodayViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    /// ViewModel under test.
    private var viewModel: TodayViewModel!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        viewModel = TodayViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    /// Tests that toggling task creation view updates the correct flag (popup or fullscreen).
    func testToggleShowingTaskCreateView_popup() {
        viewModel.showingTaskCreateView = false
        viewModel.showingTaskCreateViewFullscreen = false
        
        viewModel.toggleShowingTaskCreateView()
        
        XCTAssertTrue(viewModel.showingTaskCreateView || viewModel.showingTaskCreateViewFullscreen,
                      "Either showingTaskCreateView or showingTaskCreateViewFullscreen should become true after toggling.")
    }
    
    /// Tests that toggling task editing clears the selected task.
    func testToggleShowingTaskEditView() {
        let task = TaskEntity()
        viewModel.selectedTask = task
        viewModel.toggleShowingTaskEditView()
        
        XCTAssertNil(viewModel.selectedTask,
                     "Selected task should be nil after calling toggleShowingTaskEditView().")
    }
    
    /// Tests that toggling the search bar visibility works correctly.
    func testToggleShowingSearchBar() {
        viewModel.showingSearchBar = false
        viewModel.toggleShowingSearchBar()
        
        XCTAssertTrue(viewModel.showingSearchBar,
                      "showingSearchBar should be true after toggling from false.")
    }
    
    /// Tests that toggling the importance filter works correctly.
    func testToggleImportance() {
        viewModel.importance = false
        viewModel.toggleImportance()
        
        XCTAssertTrue(viewModel.importance,
                      "importance should be true after toggling from false.")
    }
}
