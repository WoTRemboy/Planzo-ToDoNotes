//
//  ToDoNotesApp.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI
import GoogleSignIn

@main
struct ToDoNotesApp: App {
    
    // MARK: - Properties
        
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
        }
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
