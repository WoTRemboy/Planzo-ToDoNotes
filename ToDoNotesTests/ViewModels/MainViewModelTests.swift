//
//  MainViewModelTests.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/04/2025.
//

import XCTest
@testable import ToDoNotes

/// Unit tests for the `MainViewModel`.
/// Tests task filtering, folder selection, search bar toggling, and task creation workflows.
final class MainViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: MainViewModel!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        viewModel = MainViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Filter and Folder Selection Tests
    
    /// Tests that setting a new filter updates the `selectedFilter` property.
    func test_SetFilter_ShouldUpdateSelectedFilter() {
        viewModel.setFilter(to: .completed)
        XCTAssertEqual(viewModel.selectedFilter, .completed)
    }
    
    /// Tests that `compareFilters` returns `true` only when comparing with the active filter.
    func test_CompareFilters_ShouldReturnTrue_WhenMatchingFilter() {
        viewModel.setFilter(to: .active)
        XCTAssertTrue(viewModel.compareFilters(with: .active))
        XCTAssertFalse(viewModel.compareFilters(with: .completed))
    }
    
    /// Tests that setting a new folder updates the `selectedFolder` property.
    func test_SetFolder_ShouldUpdateSelectedFolder() {
        viewModel.setFolder(to: .reminders)
        XCTAssertEqual(viewModel.selectedFolder, .reminders)
    }
    
    /// Tests that `compareFolders` returns `true` only when comparing with the active folder.
    func test_CompareFolders_ShouldReturnTrue_WhenMatchingFolder() {
        viewModel.setFolder(to: .tasks)
        XCTAssertTrue(viewModel.compareFolders(with: .tasks))
        XCTAssertFalse(viewModel.compareFolders(with: .lists))
    }
    
    /// Tests that toggling importance changes the `importance` property.
    func test_ToggleImportance_ShouldToggleValue() {
        let initialValue = viewModel.importance
        viewModel.toggleImportance()
        XCTAssertNotEqual(viewModel.importance, initialValue)
    }
    
    // MARK: - Visibility Toggles Tests
    
    /// Tests that toggling showing create view properly updates popup or full-screen state.
    func test_ToggleShowingCreateView_ShouldUpdatePopupOrFullscreen() {
        viewModel.selectedFolder = .all
        viewModel.toggleShowingCreateView()
        XCTAssertTrue(viewModel.showingTaskCreateView || viewModel.showingTaskCreateViewFullscreen)
    }
    
    /// Tests that toggling the edit view clears the selected task.
    func test_ToggleShowingTaskEditView_ShouldClearSelectedTask() {
        let dummyTask = TaskEntity()
        viewModel.selectedTask = dummyTask
        viewModel.toggleShowingTaskEditView()
        XCTAssertNil(viewModel.selectedTask)
    }
    
    /// Tests that the task remove alert visibility is toggled.
    func test_ToggleShowingTaskRemoveAlert_ShouldToggleValue() {
        let initial = viewModel.showingTaskRemoveAlert
        viewModel.toggleShowingTaskRemoveAlert()
        XCTAssertNotEqual(viewModel.showingTaskRemoveAlert, initial)
    }
    
    /// Tests that the edit removed alert visibility is toggled.
    func test_ToggleShowingEditRemovedAlert_ShouldToggleValue() {
        let initial = viewModel.showingTaskEditRemovedAlert
        viewModel.toggleShowingEditRemovedAlert()
        XCTAssertNotEqual(viewModel.showingTaskEditRemovedAlert, initial)
    }
    
    /// Tests that the search bar visibility is toggled.
    func test_ToggleShowingSearchBar_ShouldToggleValue() {
        let initial = viewModel.showingSearchBar
        viewModel.toggleShowingSearchBar()
        XCTAssertNotEqual(viewModel.showingSearchBar, initial)
    }
    
    // MARK: - Task Filtering Tests (Folders)
    
    /// Tests that tasks are correctly matched to the selected folder.
    func test_TaskMatchesFolder_ShouldMatchCorrectly() {
        let task = makeDummyTaskEntity()
        
        task.folder = Folder.tasks.rawValue
        viewModel.selectedFolder = .tasks
        XCTAssertTrue(viewModel.taskMatchesFolder(for: task))
        
        viewModel.selectedFolder = .reminders
        XCTAssertFalse(viewModel.taskMatchesFolder(for: task))
        
        viewModel.selectedFolder = .all
        XCTAssertTrue(viewModel.taskMatchesFolder(for: task))
    }
    
    // MARK: - Task Filtering Tests (Filters)
    
    /// Tests that an active (incomplete) task matches the active filter.
    func test_TaskMatchesFilter_ActiveTask_ShouldMatch() {
        let task = makeDummyTaskEntity()
        task.completed = 1
        task.removed = false
        task.hasTargetTime = false
        
        viewModel.setFilter(to: .active)
        XCTAssertTrue(viewModel.taskMatchesFilter(for: task))
    }
    
    /// Tests that a completed task matches the completed filter.
    func test_TaskMatchesFilter_CompletedTask_ShouldMatch() {
        let task = makeDummyTaskEntity()
        task.completed = 2
        task.removed = false
        
        viewModel.setFilter(to: .completed)
        XCTAssertTrue(viewModel.taskMatchesFilter(for: task))
    }
    
    /// Tests that a deleted task matches only when the deleted filter is selected.
    func test_TaskMatchesFilter_DeletedTask_ShouldMatchOnlyInDeletedFilter() {
        let task = makeDummyTaskEntity()
        task.removed = true
        
        viewModel.setFilter(to: .deleted)
        XCTAssertTrue(viewModel.taskMatchesFilter(for: task))
        
        viewModel.setFilter(to: .active)
        XCTAssertFalse(viewModel.taskMatchesFilter(for: task))
    }
    
    /// Tests that an outdated task (past due) matches the outdated filter.
    func test_TaskMatchesFilter_OutdatedTask_ShouldMatch() {
        let task = makeDummyTaskEntity()
        task.completed = 1
        task.hasTargetTime = true
        task.target = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        task.removed = false
        
        viewModel.setFilter(to: .outdated)
        XCTAssertTrue(viewModel.taskMatchesFilter(for: task))
    }
    
    /// Tests that an archived task (past due but incomplete) matches the archived filter.
    func test_TaskMatchesFilter_ArchivedTask_ShouldMatch() {
        let task = makeDummyTaskEntity()
        task.completed = 0
        task.hasTargetTime = true
        task.target = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        task.removed = false
        
        viewModel.setFilter(to: .archived)
        XCTAssertTrue(viewModel.taskMatchesFilter(for: task))
    }
    
    /// Tests that an unsorted (non-deleted) task matches the unsorted filter.
    func test_TaskMatchesFilter_Unsorted_ShouldMatchAnyNonRemovedTask() {
        let task = makeDummyTaskEntity()
        task.removed = false
        
        viewModel.setFilter(to: .unsorted)
        XCTAssertTrue(viewModel.taskMatchesFilter(for: task))
    }
    
    private func makeDummyTaskEntity() -> TaskEntity {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        return TaskEntity(context: context)
    }
}
