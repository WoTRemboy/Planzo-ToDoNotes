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
        
        static let appleLogin = "Войти с помощью Apple"
        static let googleLogin = "Войти с помощью Google"
        static let withoutAuth = "Без авторизации"
        
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
            static let title = "Папки"
            static let all = "Все"
            static let noDate = "Без дат"
            static let purchases = "Покупки"
            static let passwords = "Пароли"
        }
    }
    
    enum TodayPage {
        static let title = "Сегодня"
        static let placeholder = "У вас пока нет заметок"
    }
    
    enum CalendarPage {
        static let title = "Календарь"
        static let today = "Сегодня"
        static let emptyList = "Свободный день"
    }
    
    enum Settings {
        static let title = "Настройки"
        static let cancel = "Отмена"
        
        enum About {
            static let title = "О приложении"
            static let release = "release"
        }
        
        enum Language {
            static let sectionTitle = "Основные"
            static let title = "Язык"
            static let details = "Русский"
            
            static let alertTitle = "Сменить язык"
            static let alertContent = "Выберите нужный язык в настройках."
            static let settings = "Настройки"
        }
        
        enum Appearance {
            static let title = "Оформление"
            static let system = "Системное"
            static let light = "Светлое"
            static let dark = "Тёмное"
        }
        
        enum Email {
            static let contact = "Контакт"
            static let emailTitle = "Email"
            static let emailContent = "contact@avoqode.com"
        }
    }
    
    enum TaskManagement {
        static let titlePlaceholder = "Что бы вы хотели сделать?"
        static let descriprionPlaceholder = "Описание"
        static let today = "Сегодня"
        static let point = "Пункт"
        
        enum ShareView {
            static let title = "Совместный доступ"
            static let view = "Просмотр"
            static let edit = "Редактирование"
            static let link = "Получение ссылки..."
        }
    }
    
    enum Tabbar {
        static let main = "Главная"
        static let today = "Сегодня"
        static let calendar = "Календарь"
        static let settings = "Настройки"
    }
    
    enum DateParameters {
        static let locale = "ru_RU"
    }
    
    enum CoreData {
        static let container = "TaskModel"
        static let entity = "TaskEntity"
    }
    
    enum UserDefaults {
        static let skipOnboarding = "skipOnboarding"
        static let notifications = "notificationsEnabled"
        static let theme = "userTheme"
    }
}
