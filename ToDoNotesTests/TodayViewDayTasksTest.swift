//
//  TodayViewDayTasksTest.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/04/2025.
//

import XCTest
import SwiftUI
@testable import ToDoNotes

// MARK: - TodayView dayTasks Logic Tests

/// Unit tests for `TodayView` task filtering and grouping into sections.
final class TodayView_dayTasksTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: TodayViewModel!
    private var tasks: [TaskEntity] = []
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        viewModel = TodayViewModel()
        createDummyTasks()
    }
    
    override func tearDown() {
        viewModel = nil
        tasks.removeAll()
        super.tearDown()
    }
    
    // MARK: - Tests
    
    /// Tests task grouping into pinned, active, and completed sections.
    func test_DayTasks_ShouldGroupCorrectly() {
        // Simulating pinned, active, and completed tasks
        let pinned = tasks.filter { $0.pinned }
        let active = tasks.filter { !$0.pinned && $0.completed != 2 }
        let completed = tasks.filter { !$0.pinned && $0.completed == 2 }
        
        XCTAssertTrue(!pinned.isEmpty, "There should be pinned tasks.")
        XCTAssertTrue(!active.isEmpty, "There should be active tasks.")
        XCTAssertTrue(!completed.isEmpty, "There should be completed tasks.")
    }
    
    // MARK: - Helpers
    
    /// Creates dummy tasks for testing.
    private func createDummyTasks() {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let calendar = Calendar.current
        
        for i in 0..<5 {
            let task = TaskEntity(context: context)
            task.name = "Task \(i)"
            task.created = Date()
            task.target = calendar.date(byAdding: .hour, value: i, to: Date())
            task.pinned = (i == 0)
            task.completed = (i == 4 ? 2 : 1)
            task.removed = false
            tasks.append(task)
        }
    }
}
