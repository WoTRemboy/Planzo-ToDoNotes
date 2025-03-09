//
//  SettingsView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct SettingsView: View {
    
//    @EnvironmentObject private var coreDataManager: CoreDataViewModel
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    internal var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SettingsNavBar()
                    .zIndex(1)
                
                paramsButtons
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .popView(isPresented: $viewModel.showingAppearance, onDismiss: {}) {
            SettingAppearanceView()
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
    
    private var paramsButtons: some View {
        ScrollView {
            VStack(spacing: 0) {
                appearanceButton
                notificationRow
                    .onAppear {
                        viewModel.readNotificationStatus()
                    }
                languageButton
//                resetButton
                taskCreatePageButton
            }
            .clipShape(.rect(cornerRadius: 10))
            .padding([.horizontal, .top])
            
            
            aboutAppButton
                .clipShape(.rect(cornerRadius: 10))
                .padding(.horizontal)
        }
        .scrollContentBackground(.hidden)
    }
    
    private var aboutAppSection: some View {
        Section {
            AboutAppView(name: viewModel.appName,
                         version: viewModel.appVersion)
        } header: {
            Text(Texts.Settings.About.title)
                .font(.system(size: 13, weight: .medium))
                .textCase(.none)
        }
    }
    
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
    
    private var notificationRow: some View {
        ZStack(alignment: .trailing) {
            SettingFormRow(
                title: Texts.Settings.Notification.title,
                image: Image.Settings.notifications)
            
            notificationToggle
                .padding(.trailing, 14)
        }
    }
    
    private var notificationToggle: some View {
        Toggle(isOn: $viewModel.notificationsEnabled) {}
            .fixedSize()
            .background(Color.BackColors.backFormCell)
            .tint(Color.black)
            .scaleEffect(0.8)
        
            .onChange(of: viewModel.notificationsEnabled) { _, newValue in
                setNotificationsStatus(allowed: newValue)
            }
    }
    
//    private var resetButton: some View {
//        Button {
//            if !coreDataManager.savedEnities.isEmpty {
//                viewModel.toggleShowingResetDialog()
//            } else {
//                viewModel.resetMessage = .empty
//                viewModel.showingResetResult.toggle()
//            }
//        } label: {
//            SettingFormRow(title: Texts.Settings.Reset.title,
//                           image: Image.Settings.reset,
//                           chevron: true)
//        }
//        .confirmationDialog(Texts.Settings.Reset.warning,
//                            isPresented: $viewModel.showingResetDialog,
//                            titleVisibility: .visible) {
//            Button(role: .destructive) {
//                coreDataManager.deleteAllTasksAndClearNotifications { success in
//                    if success {
//                        viewModel.resetMessage = .success
//                    } else {
//                        viewModel.resetMessage = .failure
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        viewModel.showingResetResult.toggle()
//                    }
//                }
//            } label: {
//                Text(Texts.Settings.Reset.confirm)
//            }
//        }
//    }
    
    private var taskCreatePageButton: some View {
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
    }
    
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

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}


extension SettingsView {
    private func setNotificationsStatus(allowed: Bool) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            DispatchQueue.main.async {
                if success {
                    viewModel.setupNotificationStatus(for: allowed)
//                    if allowed {
//                        coreDataManager.restoreNotificationsForAllTasks { complete in
//                            if complete {
//                                print("Restoration complete: Notifications have been restored.")
//                            } else {
//                                print("Restoration failed.")
//                            }
//                        }
//                    } else {
//                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//                    }
                    print("Notifications are set to \(allowed).")
                } else if let error {
                    print(error.localizedDescription)
                } else {
                    viewModel.notificationsProhibited()
                    print("Notifications are prohibited.")
                }
            }
        }
        }
}
