//
//  CalendarViewModelTests.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/04/2025.
//

import XCTest
@testable import ToDoNotes

/// Unit tests for the CalendarViewModel
final class CalendarViewModelTests: XCTestCase {
    
    private var viewModel: CalendarViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = CalendarViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }
    
    /// Tests that the initial state of CalendarViewModel is correctly configured.
    func testInitialState() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.selectedDate, Date.now.startOfDay)
        XCTAssertEqual(viewModel.calendarDate.startOfDay, Date.now.startOfDay)
        XCTAssertFalse(viewModel.showingTaskCreateView)
        XCTAssertFalse(viewModel.showingCalendarSelector)
        XCTAssertFalse(viewModel.showingTaskCreateViewFullscreen)
        XCTAssertFalse(viewModel.addTaskButtonGlow)
        XCTAssertFalse(viewModel.days.isEmpty)
    }
    
    /// Tests toggling the creation view presentation logic.
    func testToggleShowingTaskCreateView() {
        viewModel.showingTaskCreateView = false
        viewModel.showingTaskCreateViewFullscreen = false
        viewModel.toggleShowingTaskCreateView()
        
        XCTAssertTrue(viewModel.showingTaskCreateView || viewModel.showingTaskCreateViewFullscreen)
    }
    
    /// Tests toggling the calendar selector overlay.
    func testToggleShowingCalendarSelector() {
        XCTAssertFalse(viewModel.showingCalendarSelector)
        
        viewModel.toggleShowingCalendarSelector()
        XCTAssertTrue(viewModel.showingCalendarSelector)
        
        viewModel.toggleShowingCalendarSelector()
        XCTAssertFalse(viewModel.showingCalendarSelector)
    }
    
    /// Tests resetting the selected task.
    func testToggleShowingTaskEditView() {
        viewModel.selectedTask = TaskEntity()
        viewModel.toggleShowingTaskEditView()
        
        XCTAssertNil(viewModel.selectedTask)
    }
    
    /// Tests restoring today's date if a different date was selected.
    func testRestoreTodayDate() {
        let differentDate = Calendar.current.date(byAdding: .day, value: -5, to: Date.now)!
        viewModel.calendarDate = differentDate
        
        XCTAssertNotEqual(viewModel.calendarDate.startOfDay, Date.now.startOfDay)
        
        viewModel.restoreTodayDate()
        
        XCTAssertEqual(viewModel.calendarDate.startOfDay, Date.now.startOfDay)
    }
    
    /// Tests that changing the calendarDate updates the displayed days.
    func testCalendarUpdatesDaysAndSelectedDate() {
        let futureDate = Calendar.current.date(byAdding: .month, value: 1, to: Date.now)!
        
        viewModel.calendarDate = futureDate
        
        XCTAssertEqual(viewModel.selectedDate, Calendar.current.startOfDay(for: futureDate))
        XCTAssertFalse(viewModel.days.isEmpty)
    }
}
