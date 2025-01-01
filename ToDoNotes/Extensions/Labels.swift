//
//  Labels.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import Foundation

final class Texts {
    enum SplashScreen {
        static let title = "Splash Screen"
    }
    
    enum OnboardingPage {
        static let skip = "Пропустить"
        static let next = "Продолжить"
        static let start = "Начать"
        
        static let placeholderTitle = "Добро пожаловать\nв Список дел"
        static let placeholderContent = "Вот небольшое руководство, чтобы помочь вам начать."
    }
    
    enum UserDefaults {
        static let skipOnboarding = "skipOnboarding"
        static let notifications = "notificationsEnabled"
        static let theme = "userTheme"
    }
}
