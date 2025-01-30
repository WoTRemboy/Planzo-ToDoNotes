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
            static let purchases = "Списки"
            static let passwords = "Пароли"
        }
    }
    
    enum TodayPage {
        static let title = "Сегодня"
        static let placeholder = "У вас пока нет заметок"
        static let notCompleted = "Не выполнено"
        static let completed = "Выполнено"
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
        
        enum Notification {
            static let title = "Уведомления"
            static let alertTitle = "Требуется доступ"
            static let alertContent = "Пожалуйста, включите уведомления в настройках."
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
        
        enum DatePicker {
            static let title = "Дата и время"
            static let cancel = "Отменить"
            static let done = "Сохранить"
            static let target = "Цель"
            static let time = "Время"
            static let remainder = "Напоминание"
            static let cycle = "Повтор"
            static let endCycle = "Завершить повторы"
            static let removeAll = "Очистить всё"
            
            static let noneTime = "Нет"
            
            static let noneReminder = "Нет"
            static let inTime = "Во время"
            static let fiveMinutesBefore = "За 5 минут"
            static let thirtyMinutesBefore = "За 30 минут"
            static let oneHourBefore = "За 1 час"
            static let oneDayBefore = "За 1 день"
            
            static let noneRepeating = "Нет"
            static let dailyRepeating = "Каждый день"
            static let weeklyRepeating = "Каждую неделю"
            static let monthlyRepeating = "Каждый месяц"
            static let yearlyRepeating = "Каждый год"
            static let businessRepeating = "По будням"
            static let weekendRepeating = "По выходным"
            
            static let noneEndRepeating = "Никогда"
        }
        
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
    
    enum Notifications {
        static let now = "Сейчас"
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
