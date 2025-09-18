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
    
    @Published internal var showingSubscriptionPage: Bool = false
    @Published internal var showingSubscriptionDetailsPage: Bool = false
    /// Flag to show language alert popup.
    @Published internal var showingLanguageAlert: Bool = false
    @Published internal var showingErrorAlert: Bool = false
    /// Flag to show appearance selector popup.
    @Published internal var showingAppearance: Bool = false
    @Published internal var showingTimeFormat: Bool = false
    @Published internal var showingWeekFirstDay: Bool = false
    
    @Published internal var showLoginOptions: Bool = false
    @Published internal var showingLogoutConfirmation: Bool = false
    /// Flag to show reset confirmation dialog.
    @Published internal var showingResetDialog: Bool = false
    /// Flag to show reset result popup.
    @Published internal var showingResetResult: Bool = false
    /// Current reset result (success, failure, or empty).
    @Published internal var resetMessage: ResetMessage = .failure
    
    @Published internal var selectedAppearance: Theme = .systemDefault
    @Published internal var selectedTimeFormat: TimeFormat = .system
    @Published internal var selectedWeekFirstDay: WeekFirstDay = .monday
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
        self.selectedTimeFormat = TimeFormatSelector.current
        self.selectedWeekFirstDay = WeekFirstDay.setupValue(for: firstDayOfWeek)
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
    
    // MARK: - Computed Properties
    
    /// User's preferred first day of the week (1 – Sunday, 2 – Monday, 7 - Saturday).
    internal var firstDayOfWeek: Int {
        get { Date.firstDayOfWeek }
        set { Date.firstDayOfWeek = newValue }
    }
    
    // MARK: - UI Toggles
    
    internal func toggleShowingSubscriptionPage() {
        showingSubscriptionPage.toggle()
    }
    
    internal func toggleShowingSubscriptionDetailsPage() {
        showingSubscriptionDetailsPage.toggle()
    }
    
    internal func toggleShowingErrorAlert() {
        showingErrorAlert.toggle()
    }
    
    /// Toggles the display of the language alert.
    internal func toggleShowingLanguageAlert() {
        showingLanguageAlert.toggle()
    }
    
    /// Toggles the display of the appearance selector.
    internal func toggleShowingAppearance() {
        showingAppearance.toggle()
    }
    
    internal func toggleShowingTimeFormat() {
        showingTimeFormat.toggle()
    }
    
    internal func toggleShowingWeekFirstDay() {
        showingWeekFirstDay.toggle()
    }
    
    /// Toggles the display of the reset confirmation dialog.
    internal func toggleShowingResetDialog() {
        showingResetDialog.toggle()
    }
    
    internal func toggleShowingLogoutConfirmation() {
        showingLogoutConfirmation.toggle()
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
    
    internal func handleGoogleSignIn(googleAuthService: GoogleAuthService) {
        guard let topVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) })
            .first?.rootViewController else {
            logger.error("Top view controller not found for Google Sign-In presentation.")
            return
        }
        hideLoginOptions()
        
        googleAuthService.signInWithGoogle(presentingViewController: topVC) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.showingErrorAlert = true
                    logger.error("Google Sign-In failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    internal func handleAppleSignIn(appleAuthService: AppleAuthService) {
        hideLoginOptions()
        LoadingOverlay.shared.show()
        
        appleAuthService.onBackendAuthResult = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                LoadingOverlay.shared.hide()
                switch result {
                case .success:
                    withAnimation(.easeInOut(duration: 0.25)) {
                        self.hideLoginOptions()
                    }
                case .failure(let error):
                    self.showingErrorAlert = true
                    logger.error("Apple Sign-In backend failed: \(error.localizedDescription)")
                }
            }
        }
        appleAuthService.onAuthError = { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                LoadingOverlay.shared.hide()
                self.showingErrorAlert = true
                logger.error("Apple Sign-In failed: \(error.localizedDescription)")
            }
        }
        appleAuthService.startAppleSignIn()
    }
    
    /// Handles logout with animation and error reporting.
    internal func handleLogout(authService: AuthNetworkService) {
        LoadingOverlay.shared.show()
        authService.logout { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                LoadingOverlay.shared.hide()
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.showingErrorAlert = true
                    logger.error("Logout failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func hideLoginOptions() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showLoginOptions = false
        }
    }
    
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
    
    /// Sets the preferred first day of the week for the calendar.
    /// - Parameter value: 1 (Sunday), 2 (Monday), 7 (Saturday)
    internal func setFirstDayOfWeek(to value: WeekFirstDay) {
        self.firstDayOfWeek = value.rawValue
        logger.debug("User changed firstDayOfWeek to: \(value.name)")
    }
    
    /// Changes the application's time format (system, 12-hour, or 24-hour).
    /// - Parameter format: The selected `TimeFormat`.
    internal func changeTimeFormat(to format: TimeFormat) {
        selectedTimeFormat = format
        TimeFormatSelector.current = format
        logger.debug("User changed time format to: \(format.rawValue)")
    }
}

