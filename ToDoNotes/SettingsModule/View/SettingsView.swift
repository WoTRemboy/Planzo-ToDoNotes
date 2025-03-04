//
//  SettingsView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var coreDataManager: CoreDataViewModel
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
                contentSection
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
        
        .alert(isPresented: $viewModel.showingLanguageAlert) {
            // Change language alert
            Alert(
                title: Text(Texts.Settings.Language.alertTitle),
                message: Text(Texts.Settings.Language.alertContent),
                primaryButton: .default(Text(Texts.Settings.Language.settings)) {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                },
                secondaryButton: .cancel(Text(Texts.Settings.cancel))
            )
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
        .alert(isPresented: $viewModel.showingNotificationAlert) {
            Alert(
                title: Text(Texts.Settings.Notification.prohibitedTitle),
                message: Text(Texts.Settings.Notification.alertContent),
                primaryButton: .default(Text(Texts.Settings.title)) {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                },
                secondaryButton: .cancel(Text(Texts.Settings.cancel))
            )
        }
    }
    
    private var contentSection: some View {
        resetButton
            .alert(isPresented: $viewModel.showingResetResult) {
                Alert(
                    title: Text(viewModel.resetMessage.title),
                    message: Text(viewModel.resetMessage.message),
                    dismissButton: .cancel(Text(Texts.Settings.ok))
                )
            }
    }
    
    private var resetButton: some View {
        Button {
            if !coreDataManager.savedEnities.isEmpty {
                viewModel.toggleShowingResetDialog()
            } else {
                viewModel.resetMessage = .empty
                viewModel.showingResetResult.toggle()
            }
        } label: {
            SettingFormRow(title: Texts.Settings.Reset.title,
                           image: Image.Settings.reset,
                           chevron: true)
        }
        .confirmationDialog(Texts.Settings.Reset.warning,
                            isPresented: $viewModel.showingResetDialog,
                            titleVisibility: .visible) {
            Button(role: .destructive) {
                withAnimation {
                    coreDataManager.deleteAllTasksAndClearNotifications { success in
                        if success {
                            viewModel.resetMessage = .success
                        } else {
                            viewModel.resetMessage = .failure
                        }
                        viewModel.showingResetResult.toggle()
                    }
                }
            } label: {
                Text(Texts.Settings.Reset.confirm)
            }
        }
    }
    
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
                    if allowed {
                        coreDataManager.restoreNotificationsForAllTasks { complete in
                            if complete {
                                print("Restoration complete: Notifications have been restored.")
                            } else {
                                print("Restoration failed.")
                            }
                        }
                    } else {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
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
