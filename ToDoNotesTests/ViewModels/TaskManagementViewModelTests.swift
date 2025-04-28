//
//  TaskManagementViewModelTests.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 28/04/2025.
//

import XCTest
import SwiftUI
@testable import ToDoNotes

/// Unit tests for the TaskManagementViewModel.
final class TaskManagementViewModelTests: XCTestCase {

    private var viewModel: TaskManagementViewModel!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        viewModel = TaskManagementViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    /// Tests the default initial state of the view model.
    func testInitialState() {
        XCTAssertEqual(viewModel.nameText, "")
        XCTAssertEqual(viewModel.descriptionText, "")
        XCTAssertEqual(viewModel.check, .none)
        XCTAssertFalse(viewModel.hasDate)
        XCTAssertFalse(viewModel.hasTime)
        XCTAssertTrue(viewModel.checklistLocal.isEmpty)
    }

    // MARK: - Toggle Methods Tests

    /// Tests toggling the importance flag.
    func testToggleImportance() {
        viewModel.toggleImportanceCheck()
        XCTAssertTrue(viewModel.importance)
    }

    /// Tests toggling the pinned flag.
    func testTogglePinned() {
        viewModel.togglePinnedCheck()
        XCTAssertTrue(viewModel.pinned)
    }

    /// Tests toggling the removed flag.
    func testToggleRemoved() {
        viewModel.toggleRemoved()
        XCTAssertTrue(viewModel.removed)
    }

    /// Tests toggling the bottom task check state.
    func testToggleBottomCheck() {
        XCTAssertEqual(viewModel.check, .none)
        viewModel.toggleBottomCheck()
        XCTAssertEqual(viewModel.check, .unchecked)
        viewModel.toggleBottomCheck()
        XCTAssertEqual(viewModel.check, .none)
    }

    /// Tests toggling the title check state.
    func testToggleTitleCheck() {
        viewModel.toggleTitleCheck()
        XCTAssertEqual(viewModel.check, .unchecked)
    }

    /// Tests showing the share sheet.
    func testToggleShareSheet() {
        viewModel.toggleShareSheet()
        XCTAssertTrue(viewModel.showingShareSheet)
    }

    /// Tests showing the date picker.
    func testToggleDatePicker() {
        viewModel.toggleDatePicker()
        XCTAssertTrue(viewModel.showingDatePicker)
    }

    /// Tests showing the notification alert.
    func testToggleShowingNotificationAlert() {
        viewModel.toggleShowingNotificationAlert()
        XCTAssertTrue(viewModel.showingNotificationAlert)
    }

    // MARK: - Checklist Management Tests

    /// Tests appending a new checklist item.
    func testAddChecklistItem() {
        viewModel.appendChecklistItem()
        XCTAssertEqual(viewModel.checklistLocal.count, 1)
    }

    /// Tests removing a checklist item (only if more than one exists).
    func testRemoveChecklistItem() {
        viewModel.appendChecklistItem()
        let id = viewModel.checklistLocal.first?.id
        XCTAssertNotNil(id)
        viewModel.removeChecklistItem(for: id!)
        XCTAssertEqual(viewModel.checklistLocal.count, 1, "Should keep at least one checklist item")
    }

    /// Tests toggling checklist item completion.
    func testToggleChecklistComplete() {
        viewModel.appendChecklistItem()
        let binding = Binding(get: { self.viewModel.checklistLocal[0] },
                              set: { self.viewModel.checklistLocal[0] = $0 })
        viewModel.toggleChecklistComplete(for: binding)
        XCTAssertTrue(viewModel.checklistLocal.first!.completed)
    }

    // MARK: - Calendar Navigation Tests

    /// Tests moving the calendar month forward.
    func testCalendarMonthMoveForward() {
        let originalDate = viewModel.calendarDate
        viewModel.calendarMonthMove(for: .forward)
        XCTAssertNotEqual(originalDate, viewModel.calendarDate)
    }

    /// Tests moving the calendar month backward.
    func testCalendarMonthMoveBackward() {
        let originalDate = viewModel.calendarDate
        viewModel.calendarMonthMove(for: .backward)
        XCTAssertNotEqual(originalDate, viewModel.calendarDate)
    }

    // MARK: - Combined Date and Time Tests

    /// Tests that combining date and time without a selected time results in only day.
    func testCombinedDateTimeWithoutTime() {
        viewModel.selectedTimeType = .none
        let result = viewModel.combinedDateTime
        XCTAssertEqual(result.startOfDay, viewModel.selectedDay.startOfDay)
    }

    /// Tests that combining date and time with a selected time includes the time component.
    func testCombinedDateTimeWithTime() {
        viewModel.selectedTimeType = .value(Date())
        let result = viewModel.combinedDateTime
        XCTAssertNotNil(result)
    }

    /// Tests saving the combined date as the target date.
    func testSaveTaskDateParams() {
        viewModel.hasDate = true
        viewModel.selectedDay = Date()
        viewModel.selectedTimeType = .none
        viewModel.saveTaskDateParams()
        XCTAssertNotNil(viewModel.targetDate)
    }

    // MARK: - Menu Label & Icon Visibility Tests

    /// Tests getting correct menu labels for time, notifications, and repeating.
    func testMenuLabels() {
        XCTAssertEqual(viewModel.menuLabel(for: .time), viewModel.selectedTimeDescription)
        XCTAssertEqual(viewModel.menuLabel(for: .notifications), viewModel.selectedNotificationDescription)
        XCTAssertEqual(viewModel.menuLabel(for: .repeating), viewModel.selectedRepeatingDescription)
    }

    /// Tests visibility of default menu icons depending on selection state.
    func testShowingMenuIcon() {
        XCTAssertTrue(viewModel.showingMenuIcon(for: .time))
        XCTAssertTrue(viewModel.showingMenuIcon(for: .notifications))
    }
}
