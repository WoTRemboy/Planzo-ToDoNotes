//
//  SettingsViewIPad.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/19/25.
//

import SwiftUI
import OSLog
import UIKit

private let logger = Logger(subsystem: "com.todonotes.settings", category: "SettingsViewIPad")

struct SettingsViewIPad: View {
    @FetchRequest(entity: TaskEntity.entity(), sortDescriptors: [])
    private var tasksResults: FetchedResults<TaskEntity>

    @Namespace private var namespace

    @EnvironmentObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var authService: AuthNetworkService

    @StateObject private var appleAuthService: AppleAuthService
    @StateObject private var googleAuthService: GoogleAuthService

    init(networkService: AuthNetworkService) {
        _appleAuthService = StateObject(wrappedValue: AppleAuthService(networkService: networkService))
        _googleAuthService = StateObject(wrappedValue: GoogleAuthService(networkService: networkService))
    }

    internal var body: some View {
        VStack(spacing: 0) {
            settingsGrid
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .subscriptionPresentation(isPresented: $viewModel.showingSubscriptionPage) {
            SubscriptionView(namespace: namespace, networkService: authService)
        }
        .popView(isPresented: $viewModel.showingAppearance, onTap: {}, onDismiss: {}) {
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
        .popView(isPresented: $viewModel.showingTimeFormat, onTap: {}, onDismiss: {}) {
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
        .popView(isPresented: $viewModel.showingWeekFirstDay, onTap: {}, onDismiss: {}) {
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
        .popView(isPresented: $viewModel.showingLanguageAlert, onTap: {}, onDismiss: {}) {
            languageAlert
        }
        .popView(isPresented: $viewModel.showingNotificationAlert, onTap: {}, onDismiss: {}) {
            notificationAlert
        }
        .popView(isPresented: $viewModel.showingResetResult, onTap: {}, onDismiss: {}) {
            resetAlert
        }
        .popView(isPresented: $viewModel.showingErrorAlert, onTap: {}, onDismiss: {}) {
            errorAlert
        }
    }

    private var settingsGrid: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    profileButton
                    if authService.currentUser?.isPremium != true {
                        subscriptionPromoteRow
                    }
                    systemSettingsGroup
                    syncAboutWeekdayGroup
                    logoutButton
                }
                .frame(width: proxy.size.width * (proxy.size.height > proxy.size.width ? 0.7 : 0.5))
                .padding(.top)
                .padding(.bottom)
                .animation(.easeInOut(duration: 0.25), value: authService.currentUser)
                .frame(maxWidth: .infinity)
            }
            .scrollContentBackground(.hidden)
        }
    }

    private var settingsGridColumns: [GridItem] {
        [GridItem(.flexible(), spacing: 16)]
    }

    private var systemSettingsGroup: some View {
        VStack(spacing: 0) {
            appearanceButton
            notificationRow
                .onAppear {
                    viewModel.readNotificationStatus()
                }
            languageButton
        }
        .modifier(SystemRowCornerModifier())
    }

    private var syncAboutWeekdayGroup: some View {
        VStack(spacing: 0) {
            syncButton
            weekFirstDayButton
            aboutAppButton
        }
        .modifier(SystemRowCornerModifier())
    }
}

private extension SettingsViewIPad {
    var profileButton: some View {
        ZStack {
            if let user = authService.currentUser {
                CustomNavLink(
                    destination: SettingAccountView(namespace: namespace)
                        .environmentObject(viewModel),
                    label: {
                        SettingsProfileRow(
                            title: user.name ?? user.email,
                            image: user.avatarUrl,
                            details: planTitle,
                            chevron: true,
                            isProfile: true,
                            last: true)
                    })
                .modifier(SystemRowCornerModifier())
                .transition(.blurReplace)
            } else {
                loginOptionsView
                    .transition(.blurReplace)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authService.currentUser)
    }

    var loginOptionsView: some View {
        VStack(spacing: 12) {
            if !viewModel.showLoginOptions {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.showLoginOptions.toggle()
                    }
                } label: {
                    SettingsProfileRow(
                        title: Texts.Authorization.login,
                        last: true)
                }
                .modifier(SystemRowCornerModifier())
                .transition(.blurReplace)
            } else {
                VStack(spacing: 12) {
                    appleLoginButton
                    googleLoginButton

                    termsPolicyLabel
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.LabelColors.labelDetails)
                        .multilineTextAlignment(.center)
                        .accentColor(Color.LabelColors.Special.labelSearchBarCancel)

                    closeButton
                }
                .transition(.blurReplace.combined(with: .move(edge: .top)))
            }
        }
    }

    var appleLoginButton: some View {
        LoginButtonView(type: .apple) {
            viewModel.handleAppleSignIn(appleAuthService: appleAuthService)
        }
    }

    var googleLoginButton: some View {
        LoginButtonView(type: .google) {
            viewModel.handleGoogleSignIn(googleAuthService: googleAuthService)
        }
    }

    var termsPolicyLabel: some View {
        if let attributedText = try? AttributedString(markdown: Texts.OnboardingPage.markdownTerms) {
            return Text(attributedText)
        } else {
            return Text(Texts.OnboardingPage.markdownTermsError)
        }
    }

    var closeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                viewModel.showLoginOptions.toggle()
            }
        } label: {
            Text(Texts.Settings.hide)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
        }
    }

    var subscriptionPromoteRow: some View {
        Button {
            viewModel.toggleShowingSubscriptionPage()
        } label: {
            SubscriptionPromoteRow()
        }
        .modifier(SystemRowCornerModifier())
        .transition(.blurReplace)
        .animation(.easeInOut(duration: 0.25), value: authService.currentUser?.isPremium)
    }

    var syncButton: some View {
        CustomNavLink(
            destination: SettingSyncView(appleAuthService: appleAuthService, googleAuthService: googleAuthService)
                .environmentObject(viewModel),
            label: {
                SettingFormRow(
                    title: Texts.Settings.Sync.title,
                    image: Image.Settings.sync,
                    details: viewModel.lastSyncString(dateString: authService.currentUser?.lastSyncAt),
                    chevron: true,
                    last: false)
            })
    }

    var appearanceButton: some View {
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

    var notificationRow: some View {
        ZStack(alignment: .trailing) {
            SettingFormRow(
                title: Texts.Settings.Notification.title,
                image: Image.Settings.notifications)

            notificationToggle
                .padding(.trailing, 14)
        }
    }

    var notificationToggle: some View {
        Toggle(isOn: $viewModel.notificationsEnabled) {}
            .fixedSize()
            .background(Color.SupportColors.supportButton)
            .tint(Color.ToggleColors.notifications)
            .scaleEffect(toggleScale)
            .onChange(of: viewModel.notificationsEnabled) { _, newValue in
                setNotificationsStatus(allowed: newValue)
            }
    }

    var toggleScale: CGFloat {
        if #available(iOS 26.0, *) {
            return 1
        } else {
            return 0.8
        }
    }

    var languageButton: some View {
        Button {
            viewModel.toggleShowingLanguageAlert()
        } label: {
            SettingFormRow(
                title: Texts.Settings.Language.title,
                image: Image.Settings.language,
                details: Texts.Settings.Language.details,
                chevron: true,
                last: true)
        }
    }

    var weekFirstDayButton: some View {
        Button {
            viewModel.toggleShowingWeekFirstDay()
        } label: {
            SettingFormRow(title: Texts.Settings.WeekFirstDay.title,
                           image: Image.Settings.weekFirstDay,
                           details: WeekFirstDay.setupValue(for: viewModel.firstDayOfWeek).name,
                           chevron: true,
                           last: false)
        }
    }

    var aboutAppButton: some View {
        CustomNavLink(
            destination: SettingAboutPageView()
                .environmentObject(viewModel)) {
                    SettingFormRow(
                        title: Texts.Settings.About.title,
                        image: Image.Settings.about,
                        chevron: true,
                        last: true)
                }
    }

    var logoutButton: some View {
        ZStack {
            if authService.currentUser != nil {
                Button {
                    viewModel.toggleShowingLogoutConfirmation()
                } label: {
                    SettingLogoutButton()
                }
                .modifier(SystemRowCornerModifier())
                .transition(.blurReplace)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authService.currentUser)
        .confirmationDialog(
            Texts.Authorization.confirmLogout,
            isPresented: $viewModel.showingLogoutConfirmation,
            titleVisibility: .visible) {
                Button(role: .destructive) {
                    viewModel.handleLogout(authService: authService)
                } label: {
                    Text(Texts.Authorization.confirm)
                }
        }
    }

    var planTitle: String {
        if authService.currentUser?.isPremium == true {
            Texts.Settings.Plans.proPlan
        } else {
            Texts.Settings.Plans.freePlan
        }
    }

    var languageAlert: some View {
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

    var notificationAlert: some View {
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

    var resetAlert: some View {
        CustomAlertView(
            title: viewModel.resetMessage.title,
            message: viewModel.resetMessage.message,
            primaryButtonTitle: Texts.Settings.ok,
            primaryAction: {
                viewModel.toggleShowingResetResult()
            })
    }

    var errorAlert: some View {
        CustomAlertView(
            title: Texts.Authorization.Error.authorizationFailed,
            message: Texts.Authorization.Error.retryLater,
            primaryButtonTitle: Texts.Settings.ok,
            primaryAction: {
                viewModel.toggleShowingErrorAlert()
            })
    }

    #if DEBUG
    /// DEV ONLY: Button to reset subscription on backend and save returned tokens.
    var cancelSubscriptionDevButton: some View {
        Button {
            SubscriptionNetworkService.shared.resetLicenseDev { result in
                switch result {
                case .success(let authResponse):
                    let tokenStorage = TokenStorageService()
                    DispatchQueue.main.async {
                        tokenStorage.save(token: authResponse.accessToken, type: .accessToken)
                        tokenStorage.save(token: authResponse.refreshToken, type: .refreshToken)
                    }
                    SubscriptionCoordinatorService.shared.refreshStatus { _ in
                        DispatchQueue.main.async {
                            authService.loadPersistedProfile()
                        }
                    }
                    logger.info("DEV: subscription reset succeeded and tokens saved")
                case .failure(let error):
                    logger.error("DEV: subscription reset failed: \(error.localizedDescription)")
                }
            }
        } label: {
            SettingFormRow(
                title: "DEV: Reset subscription",
                image: Image.Settings.reset,
                chevron: false,
                last: true)
        }
        .modifier(SystemRowCornerModifier())
    }
    #endif
}

private extension SettingsViewIPad {
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
        if allowed {
            NotificationManager.shared.requestAuthorization { granted, status in
                if granted {
                    viewModel.updateNotificationStatus(.allowed)
                    TaskService.restoreNotificationsForAllTasks { complete in
                        if complete {
                            logger.debug("Restoration complete: Notifications have been restored.")
                        } else {
                            logger.error("Notifications restoration failed.")
                        }
                    }
                } else {
                    viewModel.updateNotificationStatus(status)
                    viewModel.notificationsProhibited()
                    logger.warning("Notifications are prohibited.")
                }
            }
        } else {
            viewModel.updateNotificationStatus(.disabled)
            NotificationManager.shared.removeAllTaskNotifications()
            logger.debug("Notifications are set to false.")
        }
    }
}
