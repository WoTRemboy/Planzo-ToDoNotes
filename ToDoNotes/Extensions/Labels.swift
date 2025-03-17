//
//  Labels.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import Foundation

final class Texts {
    enum SplashScreen {
        static let title = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "ToDo"
    }
    
    enum OnboardingPage {
        static let skip = NSLocalizedString("OnboardingPageSkip", comment: "Skip")
        static let next = NSLocalizedString("OnboardingPageNext", comment: "Next")
        static let start = NSLocalizedString("OnboardingPageStart", comment: "Start")
        
        static let appleLogin = NSLocalizedString("OnboardingPageAppleLogin", comment: "Sign in with Apple")
        static let googleLogin = NSLocalizedString("OnboardingPageGoogleLogin", comment: "Sign in with Google")
        static let withoutAuth = NSLocalizedString("OnboardingPageWithoutAuth", comment: "Without Authorization")
        
        static let placeholderTitle = NSLocalizedString("OnboardingPagePlaceholderTitle", comment: "Welcome to the ToDoNotes")
        static let placeholderContent = NSLocalizedString("OnboardingPagePlaceholderContent", comment: "Here's a little guide to help you get started.")
    }
    
    enum MainPage {
        static let title = NSLocalizedString("MainPageTitle", comment: "To Do List")
        static let placeholder = NSLocalizedString("MainPagePlaceholder", comment: "No notes")
        
        enum Filter {
            static let active = NSLocalizedString("MainPageFilterActive", comment: "Active")
            static let outdate = NSLocalizedString("MainPageFilterOutdate", comment: "Overdue")
            static let unsorted = NSLocalizedString("MainPageFilterUnsorted", comment: "Unsorted")
            static let completed = NSLocalizedString("MainPageFilterCompleted", comment: "Completed")
            
            enum RemoveFilter {
                static let buttonTitle = NSLocalizedString("MainPageRemoveFilterButtonTitle", comment: "Empty Trash")
                static let alertTitle = NSLocalizedString("MainPageRemoveFilterAlertTitle", comment: "Are you sure?")
                static let alertContent = NSLocalizedString("MainPageRemoveFilterAlertContent", comment: "The data will be deleted permanently.")
                static let alertCancel = NSLocalizedString("MainPageRemoveFilterAlertCancel", comment: "Cancel")
                static let alertYes = NSLocalizedString("MainPageRemoveFilterAlertYes", comment: "Yes")
            }
        }
        
        enum Folders {
            static let title = NSLocalizedString("MainPageFolderTitle", comment: "Folders")
            static let all = NSLocalizedString("MainPageFolderAll", comment: "All")
            static let reminders = NSLocalizedString("MainPageFolderReminders", comment: "Reminders")
            static let tasks = NSLocalizedString("MainPageFolderTasks", comment: "Tasks")
            static let purchases = NSLocalizedString("MainPageFolderLists", comment: "Lists")
            static let noDate = NSLocalizedString("MainPageFolderNoDates", comment: "No Dates")
        }
    }
    
    enum TodayPage {
        static let title = NSLocalizedString("TodayPageTitle", comment: "Today")
        static let placeholder = NSLocalizedString("TodayPagePlaceholder", comment: "No notes for today")
        static let notCompleted = NSLocalizedString("TodayPageActive", comment: "Active")
        static let completed = NSLocalizedString("TodayPageCompleted", comment: "Completed")
    }
    
    enum CalendarPage {
        static let title = NSLocalizedString("CalendarPageCalendarTitle", comment: "Calendar")
        static let today = NSLocalizedString("CalendarPageCalendarToday", comment: "Today")
        static let emptyList = NSLocalizedString("CalendarPageCalendarEmptyList", comment: "Free day")
        static let accept = NSLocalizedString("CalendarPageCalendarAccept", comment: "Accept")
        static let close = NSLocalizedString("CalendarPageCalendarClose", comment: "Close")
    }
    
    enum Settings {
        static let title = NSLocalizedString("SettingsPageTitle", comment: "Settings")
        static let cancel = NSLocalizedString("SettingsPageCancel", comment: "Cancel")
        static let ok = NSLocalizedString("SettingsPageOk", comment: "OK")
        
        enum About {
            static let title = NSLocalizedString("SettingsPageAboutTitle", comment: "About")
            static let release = "release"
            static let version = NSLocalizedString("SettingsPageAboutVersion", comment: "Version")
            static let copyright = "2025 Avoqode LTD"
        }
        
        enum Language {
            static let sectionTitle = NSLocalizedString("SettingsPageLanguageSectionTitle", comment: "General")
            static let title = NSLocalizedString("SettignsPageLanguageTitle", comment: "Language")
            static let details = NSLocalizedString("SettingsPageLanguageTitle", comment: "English")
            
            static let alertTitle = NSLocalizedString("SettingsPageLanguageAlertTitle", comment: "Change Language")
            static let alertContent = NSLocalizedString("SettingsPageLanguageAlertContent", comment: "Select the required language in the settings.")
            static let settings = NSLocalizedString("SettingsPageLanguageSettings", comment: "Settings")
        }
        
        enum Appearance {
            static let title = NSLocalizedString("SettingsPageAppearanceTitle", comment: "Appearance")
            static let system = NSLocalizedString("SettingsPageAppearanceSystem", comment: "System")
            static let light = NSLocalizedString("SettingsPageAppearanceLight", comment: "Light")
            static let dark = NSLocalizedString("SettingsPageAppearanceDark", comment: "Dark")
            
            static let accept = NSLocalizedString("SettingsPageAppearanceAccept", comment: "Accept")
            static let cancel = NSLocalizedString("SettingsPageAppearanceCancel", comment: "Cancel")
        }
        
        enum Notification {
            static let title = NSLocalizedString("SettingsPageNotificationsTitle", comment: "Notifications")
            static let prohibitedTitle = NSLocalizedString("SettingsPageNotificationsProhibitedTitle", comment: "Notifications are prohibited")
            static let prohibitedContent = NSLocalizedString("SettingsPageNotificationsProhibitedContent", comment: "Please enable this option in Settings.")
            static let disabledTitle = NSLocalizedString("SettingsPageNotificationsDisabledTitle", comment: "Notifications are disabled")
            static let disabledContent = NSLocalizedString("SettingsPageNotificationsDisabledContent", comment: "Please enable this option in the App Settings.")
        }
        
        enum Reset {
            static let title = NSLocalizedString("SettingsPageResetTitle", comment: "Reset")
            static let warning = NSLocalizedString("SettingsPageResetWarning", comment: "Are you sure you want to delete all existing tasks? They cannot be restored.")
            static let confirm = NSLocalizedString("SettingsPageResetConfirm", comment: "Confirm")
            
            static let success = NSLocalizedString("SettingsPageResetSuccess", comment: "Success")
            static let failure = NSLocalizedString("SettingsPageResetFailure", comment: "Failure")
            static let empty = NSLocalizedString("SettingsPageResetEmpty", comment: "Canceled")
            
            static let successMessage = NSLocalizedString("SettingsPageResetSuccessMessage", comment: "Data deleted successfully")
            static let failureMessage = NSLocalizedString("SettingsPageResetFailureMessage", comment: "Failed to delete data")
            static let emptyMessage = NSLocalizedString("SettingsPageResetEmptyMessage", comment: "The data is no longer available")
        }
        
        enum TaskCreate {
            static let title = NSLocalizedString("SettingsPageTaskCreateTitle", comment: "Create note window")
            static let popup = NSLocalizedString("SettingsPageTaskCreatePopup", comment: "Pop-up Window")
            static let fullScreen = NSLocalizedString("SettingsPageTaskCreateFullscreen", comment: "Full Screen")
            static let descriptionContent = NSLocalizedString("SettingsPageTaskCreateDescriptionContent", comment: "Choose between Page and Pop-up styles for taking notes.")
        }
    }
    
    enum TaskManagement {
        static let titlePlaceholder = "Что бы вы хотели сделать?"
        static let descriprionPlaceholder = "Описание"
        static let today = "Сегодня"
        static let point = "Пункт"
        
        enum TaskRow {
            static let placeholder = "Нет заголовка"
        }
        
        enum ContextMenu {
            static let complete = "Завершить задачу"
            static let dublicate = "Дублировать заметку"
            static let important = "Сделать избранной"
            static let importantDeselect = "Снять избранность"
            static let pin = "Закрепить"
            static let unpin = "Открепить"
            static let delete = "Удалить"
        }
        
        enum DatePicker {
            static let title = "Дата и время"
            static let cancel = "Отменить"
            static let done = "Сохранить"
            static let target = "Цель"
            static let time = "Время"
            static let reminder = "Напоминание"
            static let cycle = "Повтор"
            static let endCycle = "Завершить повторы"
            static let removeAll = "Очистить всё"
            
            static let noneTime = "Нет"
            
            static let noneReminder = "Нет"
            static let someRemainders = "Несколько"
            static let errorRemainder = "Ошибка"
            
            static let inTime = "Во время"
            static let fiveMinutesBefore = "За 5 минут"
            static let thirtyMinutesBefore = "За 30 минут"
            static let oneHourBefore = "За 1 час"
            static let oneDayBefore = "За 1 день"
            
            static let inTimeNotification = "Сейчас"
            static let fiveMinutesBeforeNotification = "Через 5 минут"
            static let thirtyMinutesBeforeNotification = "Через 30 минут"
            static let oneHourBeforeNotification = "Через 1 час"
            static let oneDayBeforeNotification = "Через 1 день"
            
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
    
    enum SearchBar {
        static let placeholder = "Поиск текста, заголовка"
        static let cancel = "Отмена"
    }
    
    enum Tabbar {
        static let main = "Главная"
        static let today = "Сегодня"
        static let calendar = "Календарь"
        static let settings = "Настройки"
    }
    
    enum Toasts {
        static let pinnedOn = "Закреплено"
        static let pinnedOff = "Откреплено"
        static let importantOn = "Добавлено в избранное"
        static let importantOff = "Убрано из избранного"
        
        static let deleted = "Удалено"
        static let deletedAll = "Корзина очищена"
        static let removed = "Перемещено в корзину"
        static let restored = "Восстановлено"
    }
    
    enum DateParameters {
        static let locale = "ru_RU"
    }
    
    enum CoreData {
        static let container = "TaskModel"
        static let entity = "TaskEntity"
        
        enum TaskSection {
            static let pinned = "Закреплено"
            static let active = "Активные"
            static let completed = "Выполнено"
        }
    }
    
    enum UserDefaults {
        static let skipOnboarding = "SkipOnboarding"
        static let addTaskButtonGlow = "AddTaskButtonGlow"
        static let notifications = "NotificationsEnabled"
        static let theme = "UserTheme"
        static let taskCreation = "TaskCreationPage"
    }
    
    enum NamespaceID {
        static let selectedTab = "SelectedTab"
        static let selectedCalendarCell = "SelectedCalendarCell"
        static let selectedCalendarDate = "SelectedCalendarDate"
        static let selectedEntity = "NoSelectedEntity"
        static let floatingButtons = "MainPageFloatingButtons"
    }
    
    enum AccessibilityIdentifier {
        static let tabBarShadow = "TabBarShadow"
    }
}
