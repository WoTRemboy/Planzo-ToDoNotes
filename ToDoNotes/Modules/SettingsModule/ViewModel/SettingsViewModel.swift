//
//  SettingsViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import Foundation
import SwiftUI
import UserNotifications
import OSLog

/// Logger for tracking settings changes and events.
private let logger = Logger(subsystem: "com.todonotes.settings", category: "SettingsViewModel")

/// ViewModel responsible for managing all settings-related functionality,
/// such as appearance, notifications, reset, and onboarding behaviors.
final class SettingsViewModel: ObservableObject {
    
    // MARK: - Stored Properties
        
    /// User's preferred theme (light, dark, or system default).
    @AppStorage(Texts.UserDefaults.theme)
    internal var userTheme: Theme = .systemDefault
    
    /// Preferred method for task creation (popup or fullscreen).
    @AppStorage(Texts.UserDefaults.taskCreation)
    internal var taskCreation: TaskCreation = .popup
    
    /// Notification permission status (allowed, disabled, prohibited).
    @AppStorage(Texts.UserDefaults.notifications)
    private var notificationsStatus: NotificationStatus = .prohibited
    
    /// Indicates whether the "add task" button should glow.
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow)
    private var addTaskButtonGlow: Bool = false
    
    // MARK: - UI State Properties
    
    /// Flag to show language alert popup.
    @Published internal var showingLanguageAlert: Bool = false
    /// Flag to show appearance selector popup.
    @Published internal var showingAppearance: Bool = false
    
    /// Flag to show reset confirmation dialog.
    @Published internal var showingResetDialog: Bool = false
    /// Flag to show reset result popup.
    @Published internal var showingResetResult: Bool = false
    /// Current reset result (success, failure, or empty).
    @Published internal var resetMessage: ResetMessage = .failure
    
    @Published internal var selectedAppearance: Theme = .systemDefault
    /// Whether notifications are enabled.
    @Published internal var notificationsEnabled: Bool
    /// Whether the "notifications prohibited" alert should be shown.
    @Published internal var showingNotificationAlert: Bool = false
    
    // MARK: - Initialization
    
    /// Initializes the SettingsViewModel with the current notification status.
    /// - Parameter notificationsEnabled: Whether notifications are currently enabled.
    init(notificationsEnabled: Bool) {
        self.notificationsEnabled = notificationsEnabled
        self.selectedAppearance = self.userTheme
    }
    
    // MARK: - App Info
        
    /// Name of the app.
    internal var appName: String {
        Texts.AppInfo.title
    }
    
    /// Current version of the app.
    internal var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? String()
    }
    
    /// Current build number of the app.
    internal var buildVersion: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - UI Toggles
    
    /// Toggles the display of the language alert.
    internal func toggleShowingLanguageAlert() {
        showingLanguageAlert.toggle()
    }
    
    /// Toggles the display of the appearance selector.
    internal func toggleShowingAppearance() {
        showingAppearance.toggle()
    }
    
    /// Toggles the display of the reset confirmation dialog.
    internal func toggleShowingResetDialog() {
        showingResetDialog.toggle()
    }
    
    /// Toggles the display of the reset result popup.
    internal func toggleShowingResetResult() {
        showingResetResult.toggle()
    }
    
    /// Toggles the display of the notification alert.
    internal func toggleShowingNotificationAlert() {
        showingNotificationAlert.toggle()
    }
    
    // MARK: - Functional Actions
    
    /// Changes the application's appearance theme with a smooth transition.
    /// - Parameter theme: The selected `Theme`.
    internal func changeTheme(theme: Theme) {
        userTheme = theme
        logger.debug("User changed theme to: \(theme.rawValue)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        window.overrideUserInterfaceStyle = theme.userInterfaceStyle
                    })
                    logger.debug("Applied new userInterfaceStyle: \(theme.userInterfaceStyle.rawValue)")
                } else {
                    logger.error("Failed to apply theme: No keyWindow found.")
                }
            }
        }
    }
    
    /// Reads the current notification status and updates `notificationsEnabled` accordingly.
    internal func readNotificationStatus() {
        guard notificationsStatus == .allowed else { return }
        notificationsEnabled = true
    }
    
    /// Updates the user's notification permission setting.
    /// - Parameter allowed: Whether notifications are allowed or not.
    internal func setupNotificationStatus(for allowed: Bool) {
        notificationsStatus = allowed ? .allowed : .disabled
    }
    
    /// Handles the scenario where notifications are prohibited by user.
    internal func notificationsProhibited() {
        self.notificationsStatus = .prohibited
        self.notificationsEnabled = false
        self.showingNotificationAlert = true
    }
    
    /// Changes the default task creation mode between popup and full screen.
    /// - Parameter mode: The new `TaskCreation` mode.
    internal func taskCreationChange(to mode: TaskCreation) {
        guard taskCreation != mode else {
            logger.debug("Task creation mode remains unchanged: \(mode.rawValue)")
            return
        }
        addTaskButtonGlow = false
        taskCreation = mode
        logger.debug("User changed task creation mode to: \(mode.rawValue)")
    }
}

