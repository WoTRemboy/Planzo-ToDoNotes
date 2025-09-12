//
//  SettingsView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.settings", category: "SettingsView")

/// Settings screen that provides options for appearance, language, notifications, and app data reset.
struct SettingsView: View {
    
    // MARK: - Properties
    
    /// Fetch request to access all saved tasks from Core Data.
    @FetchRequest(entity: TaskEntity.entity(), sortDescriptors: [])
    private var tasksResults: FetchedResults<TaskEntity>
    
    /// EnvironmentObject providing state management for the settings screen.
    @EnvironmentObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var authService: AuthNetworkService
    
    // MARK: - Body
    
    internal var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SettingsNavBar()
                    .zIndex(1)
                
                settingsList
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .popView(isPresented: $viewModel.showingAppearance, onDismiss: {}) {
            SelectorView<Theme>(
                title: Texts.Settings.Appearance.title,
                label: { $0.name },
                options: Theme.allCases,
                selected: $viewModel.selectedAppearance,
                onCancel: {
                    viewModel.toggleShowingAppearance()
                },
                onAccept: { _ in
                    viewModel.changeTheme(theme: viewModel.selectedAppearance)
                    viewModel.toggleShowingAppearance()
                },
                cancelTitle: Texts.Settings.cancel,
                acceptTitle: Texts.Settings.accept
            )
        }
        .popView(isPresented: $viewModel.showingTimeFormat, onDismiss: {}) {
            SelectorView<TimeFormat>(
                title: Texts.Settings.TimeFormat.title,
                label: { $0.name },
                options: TimeFormat.allCases,
                selected: $viewModel.selectedTimeFormat,
                onCancel: {
                    viewModel.toggleShowingTimeFormat()
                },
                onAccept: { _ in
                    viewModel.changeTimeFormat(to: viewModel.selectedTimeFormat)
                    viewModel.toggleShowingTimeFormat()
                },
                cancelTitle: Texts.Settings.cancel,
                acceptTitle: Texts.Settings.accept
            )
        }
        .popView(isPresented: $viewModel.showingWeekFirstDay, onDismiss: {}) {
            SelectorView<WeekFirstDay>(
                title: Texts.Settings.WeekFirstDay.title,
                label: { $0.name },
                options: WeekFirstDay.allCases,
                selected: $viewModel.selectedWeekFirstDay,
                onCancel: {
                    viewModel.toggleShowingWeekFirstDay()
                },
                onAccept: { _ in
                    viewModel.setFirstDayOfWeek(to: viewModel.selectedWeekFirstDay)
                    viewModel.toggleShowingWeekFirstDay()
                },
                cancelTitle: Texts.Settings.cancel,
                acceptTitle: Texts.Settings.accept
            )
        }
        .popView(isPresented: $viewModel.showingLanguageAlert, onDismiss: {}) {
            languageAlert
        }
        .popView(isPresented: $viewModel.showingNotificationAlert, onDismiss: {}) {
            notificationAlert
        }
        .popView(isPresented: $viewModel.showingResetResult, onDismiss: {}) {
            resetAlert
        }
    }
    
    /// Scrollable content with grouped setting options.
    private var settingsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                profileButton
                    .clipShape(.rect(cornerRadius: 10))
                    .padding([.horizontal, .top])
                
                VStack(spacing: 0) {
                    appearanceButton
                    notificationRow
                        .onAppear {
                            viewModel.readNotificationStatus()
                        }
                    languageButton
                    resetTasksButton
                    taskCreationSettingsButton
                }
                .clipShape(.rect(cornerRadius: 10))
                .padding(.horizontal)
                
                VStack(spacing: 0) {
                    timeFormatButton
                    weekFirstDayButton
                }
                .clipShape(.rect(cornerRadius: 10))
                .padding([.horizontal])
                
                aboutAppButton
                
                if let _ = authService.currentUser {
                    logoutButton
                }
            }
            .padding(.bottom)
        }
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Individual Setting Items
    
    private var profileButton: some View {
        Group {
            if let user = authService.currentUser {
                CustomNavLink(
                    destination: SettingAccountView()
                        .environmentObject(authService),
                    label: {
                        SettingsProfileRow(
                            title: user.name,
                            image: user.avatarUrl,
                            details: Texts.Authorization.Details.freePlan,
                            chevron: true)
                    })
            } else {
                Button {
                    // Sign In Button Action
                } label: {
                    SettingsProfileRow()
                }
            }
        }
    }
    
    /// Button to open appearance customization modal.
    private var appearanceButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleShowingAppearance()
            }
        } label: {
            SettingFormRow(
                title: Texts.Settings.Appearance.title,
                image: Image.Settings.appearance,
                details: viewModel.userTheme.name,
                chevron: true)
            .animation(.easeInOut(duration: 0.2), value: viewModel.userTheme)
        }
    }
    
    /// Row displaying notification settings with a toggle switch.
    private var notificationRow: some View {
        ZStack(alignment: .trailing) {
            SettingFormRow(
                title: Texts.Settings.Notification.title,
                image: Image.Settings.notifications)
            
            notificationToggle
                .padding(.trailing, 14)
        }
    }
    
    /// Toggle for enabling/disabling local notifications.
    private var notificationToggle: some View {
        Toggle(isOn: $viewModel.notificationsEnabled) {}
            .fixedSize()
            .background(Color.SupportColors.supportButton)
            .tint(Color.SupportColors.supportToggle)
            .scaleEffect(0.8)
        
            .onChange(of: viewModel.notificationsEnabled) { _, newValue in
                setNotificationsStatus(allowed: newValue)
            }
    }
    
    /// Button to prompt language settings update.
    private var languageButton: some View {
        Button {
            viewModel.toggleShowingLanguageAlert()
        } label: {
            SettingFormRow(
                title: Texts.Settings.Language.title,
                image: Image.Settings.language,
                details: Texts.Settings.Language.details,
                chevron: true)
        }
    }
    
    /// Button allowing the user to reset all tasks.
    private var resetTasksButton: some View {
        Button {
            handleResetAction()
        } label: {
            SettingFormRow(title: Texts.Settings.Reset.title,
                           image: Image.Settings.reset,
                           chevron: true)
        }
        .confirmationDialog(Texts.Settings.Reset.warning,
                            isPresented: $viewModel.showingResetDialog,
                            titleVisibility: .visible) {
            Button(role: .destructive) {
                performResetTasks()
            } label: {
                Text(Texts.Settings.Reset.confirm)
            }
        }
    }
    
    /// Button linking to task creation page settings.
    private var taskCreationSettingsButton: some View {
        CustomNavLink(
            destination: SettingTaskCreateView()
                .environmentObject(viewModel),
            label: {
                SettingFormRow(
                    title: Texts.Settings.TaskCreate.title,
                    image: Image.Settings.taskCreate,
                    chevron: true,
                    last: true)
            })
    }
    
    private var timeFormatButton: some View {
        Button {
            viewModel.toggleShowingTimeFormat()
        } label: {
            SettingFormRow(title: Texts.Settings.TimeFormat.title,
                           image: Image.Settings.timeformat,
                           details: TimeFormatSelector.current.name,
                           chevron: true)
        }
    }
    
    private var weekFirstDayButton: some View {
        Button {
            viewModel.toggleShowingWeekFirstDay()
        } label: {
            SettingFormRow(title: Texts.Settings.WeekFirstDay.title,
                           image: Image.Settings.weekFirstDay,
                           details: WeekFirstDay.setupValue(for: viewModel.firstDayOfWeek).name,
                           chevron: true,
                           last: true)
        }
    }
    
    /// Button leading to the "About App" page.
    private var aboutAppButton: some View {
        CustomNavLink(
            destination: SettingAboutPageView()
                .environmentObject(viewModel)) {
                    SettingFormRow(
                        title: Texts.Settings.About.title,
                        image: Image.Settings.about,
                        chevron: true,
                        last: true)
                }
                .clipShape(.rect(cornerRadius: 10))
                .padding(.horizontal)
    }
    
    private var logoutButton: some View {
        Button {
            authService.logout()
        } label: {
            SettingLogoutButton()
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding(.horizontal)
    }
    
    // MARK: - Alerts
    
    /// Displays an alert suggesting the user to open system settings to change the app's language.
    private var languageAlert: some View {
        CustomAlertView(
            title: Texts.Settings.Language.alertTitle,
            message: Texts.Settings.Language.alertContent,
            primaryButtonTitle: Texts.Settings.Language.settings,
            primaryAction: {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            },
            secondaryButtonTitle: Texts.Settings.cancel,
            secondaryAction: viewModel.toggleShowingLanguageAlert)
    }
    
    /// Displays an alert suggesting the user to open system settings to enable notifications.
    private var notificationAlert: some View {
        CustomAlertView(
            title: Texts.Settings.Notification.prohibitedTitle,
            message: Texts.Settings.Notification.prohibitedContent,
            primaryButtonTitle: Texts.Settings.title,
            primaryAction: {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            },
            secondaryButtonTitle: Texts.Settings.cancel,
            secondaryAction: viewModel.toggleShowingNotificationAlert)
    }
    
    /// Displays an alert showing the result of a reset operation.
    private var resetAlert: some View {
        CustomAlertView(
            title: viewModel.resetMessage.title,
            message: viewModel.resetMessage.message,
            primaryButtonTitle: Texts.Settings.ok,
            primaryAction: {
                viewModel.toggleShowingResetResult()
            })
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
        .environmentObject(AuthNetworkService())
}

// MARK: - Private Logic

extension SettingsView {
    /// Handles the reset button action based on the number of tasks.
    private func handleResetAction() {
        if !tasksResults.isEmpty {
            viewModel.toggleShowingResetDialog()
        } else {
            viewModel.resetMessage = .empty
            viewModel.showingResetResult.toggle()
        }
    }
    
    /// Performs task deletion and triggers a result message.
    private func performResetTasks() {
        TaskService.deleteAllTasksAndClearNotifications { success in
            if success {
                viewModel.resetMessage = .success
            } else {
                viewModel.resetMessage = .failure
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.showingResetResult.toggle()
            }
        }
    }
    
    /// Updates the notification settings based on user's permission status.
    private func setNotificationsStatus(allowed: Bool) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            DispatchQueue.main.async {
                if success {
                    viewModel.setupNotificationStatus(for: allowed)
                    if allowed {
                        TaskService.restoreNotificationsForAllTasks { complete in
                            if complete {
                                logger.debug("Restoration complete: Notifications have been restored.")
                            } else {
                                logger.error("Notifications restoration failed.")
                            }
                        }
                    } else {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                    logger.debug("Notifications are set to \(allowed).")
                } else if let error {
                    logger.error("Notifications authorization failed: \(error.localizedDescription)")
                } else {
                    viewModel.notificationsProhibited()
                    logger.warning("Notifications are prohibited.")
                }
            }
        }
    }
}
