//
//  SettingsViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import Foundation
import SwiftUI
import UserNotifications

final class SettingsViewModel: ObservableObject {
        
    @AppStorage(Texts.UserDefaults.theme) var userTheme: Theme = .systemDefault
    @AppStorage(Texts.UserDefaults.taskCreation) var taskCreation: TaskCreation = .popup
    @AppStorage(Texts.UserDefaults.notifications) private var notificationsStatus: NotificationStatus = .prohibited
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow) private var addTaskButtonGlow: Bool = false
    
    @Published internal var showingLanguageAlert: Bool = false
    @Published internal var showingAppearance: Bool = false
    
    @Published internal var showingResetDialog: Bool = false
    @Published internal var showingResetResult: Bool = false
    @Published internal var resetMessage: ResetMessage = .failure
    
    @Published internal var notificationsEnabled: Bool
    @Published internal var showingNotificationAlert: Bool = false
    
    init(notificationsEnabled: Bool) {
        self.notificationsEnabled = notificationsEnabled
    }
        
    internal var appName: String {
        Texts.AppInfo.title
    }
    
    internal var appVersion: String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return String()
    }
    
    internal func toggleShowingLanguageAlert() {
        showingLanguageAlert.toggle()
    }
    
    internal func toggleShowingAppearance() {
        showingAppearance.toggle()
    }
    
    internal func toggleShowingResetDialog() {
        showingResetDialog.toggle()
    }
    
    internal func toggleShowingResetResult() {
        showingResetResult.toggle()
    }
    
    internal func toggleShowingNotificationAlert() {
        showingNotificationAlert.toggle()
    }
    
    internal func changeTheme(theme: Theme) {
        userTheme = theme
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        window.overrideUserInterfaceStyle = theme.userInterfaceStyle
                    })
                }
            }
        }
    }
    
    internal func readNotificationStatus() {
        guard notificationsStatus == .allowed else { return }
        notificationsEnabled = true
    }
    
    internal func setupNotificationStatus(for allowed: Bool) {
        notificationsStatus = allowed ? .allowed : .disabled
    }
    
    internal func notificationsProhibited() {
        self.notificationsStatus = .prohibited
        self.notificationsEnabled = false
        self.showingNotificationAlert = true
    }
    
    internal func taskCreationChange(to mode: TaskCreation) {
        guard taskCreation != mode else { return }
        addTaskButtonGlow = false
        taskCreation = mode
    }
}
