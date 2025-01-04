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
    
    enum MainPage {
        static let title = "Список дел"
        static let placeholder = "У вас пока нет заметок"
        
        enum Filter {
            static let active = "Активные"
            static let outdate = "Просроченные"
            static let unsorted = "Несортированные"
            static let completed = "Выполненные"
        }
        
        enum Folders {
            static let all = "Все"
            static let noDate = "Без дат"
            static let purchases = "Покупки"
            static let passwords = "Пароли"
        }
    }
    
    enum Tabbar {
        static let main = "Главная"
        static let today = "Сегодня"
        static let calendar = "Календарь"
        static let settings = "Настройки"
    }
    
    enum UserDefaults {
        static let skipOnboarding = "skipOnboarding"
        static let notifications = "notificationsEnabled"
        static let theme = "userTheme"
    }
}
