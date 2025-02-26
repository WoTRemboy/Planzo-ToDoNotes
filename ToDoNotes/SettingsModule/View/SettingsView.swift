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
        NavigationStack {
            ZStack {
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            SettingsNavBar()
                .zIndex(1)
            
            paramsForm
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .fullScreenCover(isPresented: $viewModel.showingAppearance) {
            SettingAppearanceView()
                .transition(.move(edge: .leading))
        }
    }
    
    private var paramsForm: some View {
        Form {
            aboutAppSection
            applicationSection
            contentSection
            contactSection
        }
        .padding(.horizontal, hasNotch() ? -4 : 0)
        .background(Color.BackColors.backDefault)
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
        .listRowBackground(Color.SupportColors.backListRow)
    }
    
    private var applicationSection: some View {
        Section {
            // Change language button
            languageButton
            
            // Change theme button
            appearanceButton
            
            notificationToggle
                .onAppear {
                    viewModel.readNotificationStatus()
                }
        } header: {
             Text(Texts.Settings.Language.sectionTitle)
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
        .listRowBackground(Color.SupportColors.backListRow)
        
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
            viewModel.toggleShowingAppearance()
        } label: {
            SettingFormRow(
                title: Texts.Settings.Appearance.title,
                image: Image.Settings.appearance,
                details: viewModel.userTheme.name,
                chevron: true)
        }
        .listRowBackground(Color.SupportColors.backListRow)
    }
    
    private var notificationToggle: some View {
        Toggle(isOn: $viewModel.notificationsEnabled) {
            SettingFormRow(
                title: Texts.Settings.Notification.title,
                image: Image.Settings.notifications)
        }
        .onChange(of: viewModel.notificationsEnabled) { newValue in
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
        .listRowBackground(Color.SupportColors.backListRow)
    }
    
    private var contentSection: some View {
        Section {
            // Reset data button
            resetButton
        } header: {
            Text(Texts.Settings.Reset.sectionTitle)
                .font(.system(size: 13, weight: .medium))
                .textCase(.none)
        }
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
        .listRowBackground(Color.SupportColors.backListRow)
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
    
    private var contactSection: some View {
        Section {
            Link(destination: URL(string: "mailto:\(Texts.Settings.Email.emailContent)")!, label: {
                SettingFormRow(
                    title: Texts.Settings.Email.emailTitle,
                    image: Image.Settings.email,
                    details: Texts.Settings.Email.emailContent,
                    chevron: true)
            })
        } header: {
            Text(Texts.Settings.Email.contact)
                .font(.system(size: 13, weight: .medium))
                .textCase(.none)
        }
        .listRowBackground(Color.SupportColors.backListRow)
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
