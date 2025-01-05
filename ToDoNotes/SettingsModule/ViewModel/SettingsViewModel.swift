//
//  SettingsViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import Foundation
import SwiftUI

final class SettingsViewModel: ObservableObject {
    
    @AppStorage(Texts.UserDefaults.theme) var userTheme: Theme = .systemDefault
    
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
    
    internal func changeTheme(theme: Theme) {
        self.userTheme = theme
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
    
    private func versionDetect() {
        
    }
}
