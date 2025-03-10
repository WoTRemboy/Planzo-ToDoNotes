//
//  ToDoNotesApp.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI
import GoogleSignIn
import UserNotifications

@main
struct ToDoNotesApp: App {
    
    // MARK: - Properties
        
    // UserDefaults for user notifications status
    @AppStorage(Texts.UserDefaults.notifications) private var notificationsEnabled: NotificationStatus = .prohibited
    // UserDefaults for current app theme
    @AppStorage(Texts.UserDefaults.theme) private var userTheme: Theme = .systemDefault
    
    /// The app starts by displaying the `SplashScreenView` as the initial view.
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    setTheme(style: userTheme.userInterfaceStyle)
                }
                .environment(\.managedObjectContext, CoreDataProvider.shared.persistentContainer.viewContext)
        }
    }
    
    // MARK: - Initialization
    
    init() {
        requestNotifications()
    }
    
    // MARK: - Appearance setup
    
    private func setTheme(style: UIUserInterfaceStyle) {
        // System style by default
        guard style != .unspecified else { return }
        // Setups a theme style without animation
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}

// MARK: - Notifications

// Notifications Model
enum NotificationStatus: String {
    case allowed = "allowed"
    case disabled = "disabled"
    case prohibited = "prohibited"
}

// Notifications Method
extension ToDoNotesApp {
    // Requests user for alert & sound notifications
    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                // User allowes notifications & they become active
                if self.notificationsEnabled == .prohibited {
                    self.notificationsEnabled = .allowed
                }
                print("Notifications are allowed.")
            } else if let error {
                // In error case notifications become prohibited
                self.notificationsEnabled = .prohibited
                print(error.localizedDescription)
            } else {
                print("Notifications are prohibited.")
            }
        }
    }
}
