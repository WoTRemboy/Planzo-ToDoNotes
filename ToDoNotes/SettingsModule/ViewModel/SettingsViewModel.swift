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
    @AppStorage(Texts.UserDefaults.notifications) private var notificationsStatus: NotificationStatus = .prohibited
    
    @Published internal var showingLanguageAlert: Bool = false
    @Published internal var showingAppearance: Bool = false
    
    @Published internal var notificationsEnabled: Bool = false
    @Published internal var showingNotificationAlert: Bool = false
        
    internal var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown App"
    }
    
    internal var appVersion: String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(appVersion) \(Texts.Settings.About.release) \(buildVersion)"
        }
        return String()
    }
    
    init() {
        readNotificationStatus()
    }
    
    internal func toggleShowingLanguageAlert() {
        showingLanguageAlert.toggle()
    }
    
    internal func toggleShowingAppearance() {
        showingAppearance.toggle()
    }
    
    internal func changeTheme(theme: Theme) {
        userTheme = theme
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        window.overrideUserInterfaceStyle = theme.userInterfaceStyle
                    })
                }
            }
        }
    }
    
    private func readNotificationStatus() {
        guard notificationsStatus == .allowed else { return }
        notificationsEnabled = true
    }
    
    internal func setNotificationsStatus(allowed: Bool, items: [TaskEntity]) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.notificationsStatus = allowed ? .allowed : .disabled
                    if allowed {
//                        self.restoreItemsNotifications(for: items)
                    } else {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                    print("Notifications are set to \(allowed).")
                } else if let error {
                    print(error.localizedDescription)
                } else {
                    self.notificationsStatus = .prohibited
                    self.notificationsEnabled = false
                    self.showingNotificationAlert = true
                    print("Notifications are prohibited.")
                }
            }
        }
    }
#warning("Notifications methods are needed to get more optimized")
//    private func restoreItemsNotifications(for items: [TaskEntity]) {
//        let notificationsTasks = items.filter {
//            $0.notify &&
//            $0.target ?? .distantPast > .now
//        }
//        for task in notificationsTasks {
//            notificationSetup(for: task)
//        }
//    }
//    
//    // needs less overcode
//    internal func notificationSetup(for item: TaskEntity) {
//        guard let id = item.id,
//              let name = item.name,
//              let targetDate = item.target,
//              notificationsStatus == .allowed
//        else {
//            return
//        }
//        
//        let content = UNMutableNotificationContent()
//        content.title = Texts.Notifications.now
//        content.body = name
//        content.sound = .default
//        
//        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//        
//        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Notification setup error: \(error.localizedDescription)")
//            } else {
//                print("Notification successfully setup for \(name) at \(targetDate)")
//            }
//        }
//    }
}
