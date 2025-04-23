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
        
    /// Stores the current status of user notifications in UserDefaults.
    @AppStorage(Texts.UserDefaults.notifications)
    private var notificationsEnabled: NotificationStatus = .prohibited
    
    /// Stores the user's selected theme in UserDefaults.
    @AppStorage(Texts.UserDefaults.theme)
    private var userTheme: Theme = .systemDefault
    
    /// The app's main scene, launching with the splash screen and setting up appearance and context.
    internal var body: some Scene {
        WindowGroup {
            SplashScreenView()
                // Handles URL for Google Sign-In flow
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                // Applies the saved user theme on launch
                .onAppear {
                    setTheme(style: userTheme.userInterfaceStyle)
                }
                // Injects Core Data context into the environment
                .environment(\.managedObjectContext, CoreDataProvider.shared.persistentContainer.viewContext)
        }
    }
    
    // MARK: - Initialization
    
    /// App initialization. Requests user permission for notifications.
    init() {
        requestNotifications()
    }
    
    // MARK: - Appearance setup
    
    /// Sets the UI style (light, dark, or system default) without animation.
    /// - Parameter style: The desired UI user interface style.
    private func setTheme(style: UIUserInterfaceStyle) {
        // Uses system default style if none is specified
        guard style != .unspecified else { return }
        
        // Access the key window and applies the selected style
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}

// MARK: - Notifications

/// Represents the authorization status for local notifications.
enum NotificationStatus: String {
    case allowed = "allowed"
    case disabled = "disabled"
    case prohibited = "prohibited"
}

// MARK: - Notification Handling

extension ToDoNotesApp {
    /// Requests user authorization for local notifications (alerts and sounds).
    /// Updates `notificationsEnabled` based on the user's choice or errors.
    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                // Notifications were granted
                if self.notificationsEnabled == .prohibited {
                    self.notificationsEnabled = .allowed
                }
                print("Notifications are allowed.")
            } else if let error {
                // An error occurred; prohibit notifications
                self.notificationsEnabled = .prohibited
                print(error.localizedDescription)
            } else {
                // User declined notification permissions
                print("Notifications are prohibited.")
            }
        }
    }
}
