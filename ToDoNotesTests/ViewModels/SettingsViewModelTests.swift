//
//  SettingsViewModelTests.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/04/2025.
//

import XCTest
@testable import ToDoNotes

/// Unit tests for `SettingsViewModel` that cover initialization, toggling view states,
/// theme changes, notification management, and task creation mode settings.
final class SettingsViewModelTests: XCTestCase {
    
    private var viewModel: SettingsViewModel!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        viewModel = SettingsViewModel(notificationsEnabled: false)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    /// Tests that the view model initializes correctly with expected default values.
    func testInitialization() {
        XCTAssertFalse(viewModel.notificationsEnabled)
        XCTAssertFalse(viewModel.showingLanguageAlert)
        XCTAssertFalse(viewModel.showingAppearance)
    }
    
    // MARK: - Toggle State Tests
    
    /// Tests toggling the `showingLanguageAlert` property.
    func testToggleShowingLanguageAlert() {
        XCTAssertFalse(viewModel.showingLanguageAlert)
        viewModel.toggleShowingLanguageAlert()
        XCTAssertTrue(viewModel.showingLanguageAlert)
    }
    
    /// Tests toggling the `showingAppearance` property.
    func testToggleShowingAppearance() {
        XCTAssertFalse(viewModel.showingAppearance)
        viewModel.toggleShowingAppearance()
        XCTAssertTrue(viewModel.showingAppearance)
    }
    
    /// Tests toggling the `showingResetDialog` property.
    func testToggleShowingResetDialog() {
        XCTAssertFalse(viewModel.showingResetDialog)
        viewModel.toggleShowingResetDialog()
        XCTAssertTrue(viewModel.showingResetDialog)
    }
    
    /// Tests toggling the `showingResetResult` property.
    func testToggleShowingResetResult() {
        XCTAssertFalse(viewModel.showingResetResult)
        viewModel.toggleShowingResetResult()
        XCTAssertTrue(viewModel.showingResetResult)
    }
    
    /// Tests toggling the `showingNotificationAlert` property.
    func testToggleShowingNotificationAlert() {
        XCTAssertFalse(viewModel.showingNotificationAlert)
        viewModel.toggleShowingNotificationAlert()
        XCTAssertTrue(viewModel.showingNotificationAlert)
    }
    
    // MARK: - Theme Tests
    
    /// Tests changing the app's theme.
    func testChangeTheme() {
        viewModel.changeTheme(theme: .systemDefault)
        XCTAssertEqual(viewModel.userTheme, .systemDefault)
        viewModel.changeTheme(theme: .light)
        XCTAssertEqual(viewModel.userTheme, .light)
    }
    
    // MARK: - Notification Status Tests
    
    /// Tests setting the notification status to allowed.
    func testSetupNotificationStatusAllowed() {
        viewModel.setupNotificationStatus(for: true)
        XCTAssertEqual(viewModel.notificationsEnabled, false) // notificationEnabled does not update immediately
    }
    
    /// Tests setting the notification status to disabled.
    func testSetupNotificationStatusDisabled() {
        viewModel.setupNotificationStatus(for: false)
        XCTAssertEqual(viewModel.notificationsEnabled, false)
    }
    
    /// Tests behavior when notifications are prohibited by the system.
    func testNotificationsProhibited() {
        viewModel.notificationsProhibited()
        XCTAssertFalse(viewModel.notificationsEnabled)
        XCTAssertTrue(viewModel.showingNotificationAlert)
    }
    
    /// Tests reading notification status when notifications are allowed.
    func testReadNotificationStatusWhenAllowed() {
        viewModel.notificationsEnabled = false
        viewModel.setupNotificationStatus(for: true)
        viewModel.readNotificationStatus()
        XCTAssertTrue(viewModel.notificationsEnabled)
    }
    
    /// Tests reading notification status when notifications are not allowed.
    func testReadNotificationStatusWhenNotAllowed() {
        viewModel.notificationsEnabled = false
        viewModel.setupNotificationStatus(for: false)
        viewModel.readNotificationStatus()
        XCTAssertFalse(viewModel.notificationsEnabled)
    }
    
    // MARK: - Task Creation Tests
    
    /// Tests changing the task creation mode.
    func testTaskCreationChange() {
        viewModel.taskCreationChange(to: .popup)
        XCTAssertEqual(viewModel.taskCreation, .popup)
        viewModel.taskCreationChange(to: .fullScreen)
        XCTAssertEqual(viewModel.taskCreation, .fullScreen)
    }
    
    /// Tests that task creation mode does not change when setting it to the same value.
    func testTaskCreationChangeNoChange() {
        viewModel.taskCreationChange(to: .popup)
        XCTAssertEqual(viewModel.taskCreation, .popup)
        viewModel.taskCreationChange(to: .popup)
        XCTAssertEqual(viewModel.taskCreation, .popup)
    }
    
    // MARK: - App Info Tests
    
    /// Tests that the app info properties are correctly retrieved.
    func testAppInfo() {
        XCTAssertEqual(viewModel.appName, Texts.AppInfo.title)
        XCTAssertFalse(viewModel.appVersion.isEmpty)
        XCTAssertFalse(viewModel.buildVersion.isEmpty)
    }
}
