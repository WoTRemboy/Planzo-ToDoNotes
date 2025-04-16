//
//  Labels.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import Foundation

final class Texts {
    enum AppInfo {
        static let title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Planzo"
    }
    
    enum OnboardingPage {
        static let skip = NSLocalizedString("OnboardingPageSkip", comment: "Skip")
        static let next = NSLocalizedString("OnboardingPageNext", comment: "Next")
        static let start = NSLocalizedString("OnboardingPageStart", comment: "Start")
        
        static let appleLogin = NSLocalizedString("OnboardingPageAppleLogin", comment: "Sign in with Apple")
        static let googleLogin = NSLocalizedString("OnboardingPageGoogleLogin", comment: "Sign in with Google")
        static let withoutAuth = NSLocalizedString("OnboardingPageWithoutAuth", comment: "Without Authorization")
        
        static let firstTitle = NSLocalizedString("OnboardingPageFirstTitle", comment: "Here's a short guide to help you get started")
        static let secondTitle = NSLocalizedString("OnboardingPageSecondTitle", comment: "Check tasks by status. Create folders to sort things your way. Notes match folder colors")
        static let thirdTitle = NSLocalizedString("OnboardingPageThirdTitle", comment: "Create notes or tasks with due dates and reminders")
        static let fourthTitle = NSLocalizedString("OnboardingPageFourthTitle", comment: "Swipe tasks left or right for quick actions")
        static let placeholderContent = NSLocalizedString("OnboardingPagePlaceholderContent", comment: "Here's a little guide to help you get started.")
    }
    
    enum MainPage {
        static let title = NSLocalizedString("MainPageTitle", comment: "To Do List")
        static let placeholder = NSLocalizedString("MainPagePlaceholder", comment: "No Notes")
        
        enum Filter {
            static let active = NSLocalizedString("MainPageFilterActive", comment: "Active")
            static let outdate = NSLocalizedString("MainPageFilterOutdate", comment: "Overdue")
            static let unsorted = NSLocalizedString("MainPageFilterUnsorted", comment: "Unsorted")
            static let completed = NSLocalizedString("MainPageFilterCompleted", comment: "Completed")
            static let archived = NSLocalizedString("MainPageFilterArchived", comment: "Archived")
            static let deleted = NSLocalizedString("MainPageFilterDeleted", comment: "Deleted")
            
            enum RemoveFilter {
                static let buttonTitle = NSLocalizedString("MainPageRemoveFilterButtonTitle", comment: "Empty Trash")
                static let alertTitle = NSLocalizedString("MainPageRemoveFilterAlertTitle", comment: "Are you sure?")
                static let alertContent = NSLocalizedString("MainPageRemoveFilterAlertContent", comment: "The data will be deleted permanently.")
                
                static let recoverAlertTitle = NSLocalizedString("MainPageRecoverFilterAlertTitle", comment: "Recently Deleted")
                static let recoverAlertContent = NSLocalizedString("MainPageRecoverFilterAlertContent", comment: "To edit a deleted item, you'll need to recover it.")
                
                static let alertCancel = NSLocalizedString("MainPageRemoveFilterAlertCancel", comment: "Cancel")
                static let alertYes = NSLocalizedString("MainPageRemoveFilterAlertYes", comment: "Yes")
                static let alertRecover = NSLocalizedString("MainPageRemoveFilterAlertRecover", comment: "Recover")
            }
        }
        
        enum Folders {
            static let title = NSLocalizedString("MainPageFolderTitle", comment: "Folders")
            static let all = NSLocalizedString("MainPageFolderAll", comment: "All")
            static let reminders = NSLocalizedString("MainPageFolderReminders", comment: "Reminders")
            static let tasks = NSLocalizedString("MainPageFolderTasks", comment: "Tasks")
            static let purchases = NSLocalizedString("MainPageFolderLists", comment: "Lists")
            static let other = NSLocalizedString("MainPageFolderOther", comment: "Other")
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
        static let titlePlaceholder = NSLocalizedString("TaskManagementTitlePlaceholder", comment: "What would you like to do?")
        static let previewTitlePlaceholder = NSLocalizedString("TaskManagementTitlePlaceholderPreview", comment: "No title")
        static let descriprionPlaceholder = NSLocalizedString("TaskManagementDescriptionPlaceholder", comment: "Description")
        static let previewDescriprionPlaceholder = NSLocalizedString("TaskManagementDescriptionPlaceholderPreview", comment: "No description")
        static let today = NSLocalizedString("TaskManagementToday", comment: "Today")
        static let target = NSLocalizedString("TaskManagementTarget", comment: "Target")
        static let created = NSLocalizedString("TaskManagementCreated", comment: "Created")
        static let point = NSLocalizedString("TaskManagementPoint", comment: "Point")
        
        enum TaskRow {
            static let placeholder = NSLocalizedString("TaskManagementTaskRowPlaceholder", comment: "No Title")
        }
        
        enum ContextMenu {
            static let complete = NSLocalizedString("TaskManagementContextMenuComplete", comment: "Complete the Task")
            static let dublicate = NSLocalizedString("TaskManagementContextMenuDublicate", comment: "Duplicate the Note")
            static let important = NSLocalizedString("TaskManagementContextMenuImportant", comment: "Make Favorite")
            static let importantDeselect = NSLocalizedString("TaskManagementContextMenuImportantDeselect", comment: "Remove Favorite")
            static let pin = NSLocalizedString("TaskManagementContextMenuPin", comment: "Pin")
            static let unpin = NSLocalizedString("TaskManagementContextMenuUnpit", comment: "Unpin")
            static let delete = NSLocalizedString("TaskManagementContextMenuDelete", comment: "Remove")
        }
        
        enum DatePicker {
            static let title = NSLocalizedString("TaskManagementDatePickerTitle", comment: "Date & Time")
            static let cancel = NSLocalizedString("TaskManagementDatePickerCancel", comment: "Cancel")
            static let done = NSLocalizedString("TaskManagementDatePickerDone", comment: "Dane")
            static let target = NSLocalizedString("TaskManagementDatePickerTarget", comment: "Target")
            static let removeAll = NSLocalizedString("TaskManagementDatePickerRemoveAll", comment: "Clear All")
            
            enum Time {
                static let title = NSLocalizedString("TaskManagementDatePickerTime", comment: "Time")
                static let none = NSLocalizedString("TaskManagementDatePickerNoneTime", comment: "None")
            }
            
            enum Reminder {
                static let title = NSLocalizedString("TaskManagementDatePickerReminder", comment: "Reminder")
                static let none = NSLocalizedString("TaskManagementDatePickerNoneReminder", comment: "None")
                static let some = NSLocalizedString("TaskManagementDatePickerSomeReminder", comment: "Some")
                static let error = NSLocalizedString("TaskManagementDatePickerErrorReminder", comment: "Error")
                
                static let inTime = NSLocalizedString("TaskManagementDatePickerOnTime", comment: "On time")
                static let fiveMinutesBefore = NSLocalizedString("TaskManagementDatePickerFiveMinutesBefore", comment: "5 minutes before")
                static let thirtyMinutesBefore = NSLocalizedString("TaskManagementDatePickerThirtyMinutesBefore", comment: "30 minutes before")
                static let oneHourBefore = NSLocalizedString("TaskManagementDatePickerOneHourBefore", comment: "1 hour before")
                static let oneDayBefore = NSLocalizedString("TaskManagementDatePickerOneDayBefore", comment: "1 day before")
                
                static let inTimeNotification = NSLocalizedString("TaskManagementDatePickerNowNotification", comment: "Now")
                static let fiveMinutesBeforeNotification = NSLocalizedString("TaskManagementDatePickerInFiveMinutesNotification", comment: "In 5 minutes")
                static let thirtyMinutesBeforeNotification = NSLocalizedString("TaskManagementDatePickerInThiryMinutesNotification", comment: "In 30 minutes")
                static let oneHourBeforeNotification = NSLocalizedString("TaskManagementDatePickerInOneHourNotification", comment: "In 1 hour")
                static let oneDayBeforeNotification = NSLocalizedString("TaskManagementDatePickerInOneDayNotification", comment: "In 1 day")
            }
            
            enum Repeat {
                static let title = NSLocalizedString("TaskManagementDatePickerRepeatTitle", comment: "Repeat")
                static let none = NSLocalizedString("TaskManagementDatePickerRepeatNone", comment: "None")
                static let daily = NSLocalizedString("TaskManagementDatePickerRepeatEveryday", comment: "Daily")
                static let weekly = NSLocalizedString("TaskManagementDatePickerRepeatWeekly", comment: "Weekly")
                static let monthly = NSLocalizedString("TaskManagementDatePickerRepeatMonthly", comment: "Monthly")
                static let yearly = NSLocalizedString("TaskManagementDatePickerRepeatYearly", comment: "Yearly")
                static let business = NSLocalizedString("TaskManagementDatePickerRepeatBusiness", comment: "Every weekdays")
                static let weekend = NSLocalizedString("TaskManagementDatePickerRepeatWeekend", comment: "Every weekends")
                
                static let endTitle = NSLocalizedString("TaskManagementDatePickerEndRepeatTitle", comment: "End Repeat")
                static let noneEnd = NSLocalizedString("TaskManagementDatePickerEndRepeatNone", comment: "Never")
            }
        }
        
        enum ShareView {
            static let title = "Совместный доступ"
            static let view = "Просмотр"
            static let edit = "Редактирование"
            static let link = "Получение ссылки..."
        }
    }
    
    enum SearchBar {
        static let placeholder = NSLocalizedString("SearchBarPlaceholder", comment: "Search by text, title")
        static let cancel = NSLocalizedString("SearchBarCancel", comment: "Cancel")
    }
    
    enum Tabbar {
        static let main = NSLocalizedString("TabbarMainTitle", comment: "Home")
        static let today = NSLocalizedString("TabbarTodayTitle", comment: "Today")
        static let calendar = NSLocalizedString("TabbarCalendarTitle", comment: "Calendar")
        static let settings = NSLocalizedString("TabbarSettingsTitle", comment: "Settings")
    }
    
    enum Toasts {
        static let completedOn = NSLocalizedString("ToastsCompletedOn", comment: "Moved to Completed")
        static let completedError = NSLocalizedString("ToastsCompletedError", comment: "Failed to Complete")
        
        static let pinnedOn = NSLocalizedString("ToastsPinnedOn", comment: "Pinned")
        static let pinnedOff = NSLocalizedString("ToastsPinnedOff", comment: "Unpinned")
        static let importantOn = NSLocalizedString("ToastsImportantOn", comment: "Added to Favorites")
        static let importantOff = NSLocalizedString("ToastsImportantOff", comment: "Removed from Favorites")
        
        static let deleted = NSLocalizedString("ToastsDeleted", comment: "Deleted")
        static let deletedAll = NSLocalizedString("ToastsDeletedAll", comment: "Trash is clear")
        static let removed = NSLocalizedString("ToastsRemoved", comment: "Moved to Trash")
        static let restored = NSLocalizedString("ToastsRestored", comment: "Restored")
        
        static let duplicated = NSLocalizedString("ToastsDuplicated", comment: "Duplicated")
        static let duplicatedError = NSLocalizedString("ToastsDuplicatedError", comment: "Failed to Duplicate")
    }
    
    enum DateParameters {
        static let locale = NSLocalizedString("DateParametersLocale", comment: "en_US")
    }
    
    enum CoreData {
        static let container = "TaskModel"
        static let entity = "TaskEntity"
        
        enum TaskSection {
            static let pinned = NSLocalizedString("CoreDataTaskSelectionPinned", comment: "Pinned")
            static let active = NSLocalizedString("CoreDataTaskSelectionActive", comment: "Active")
            static let completed = NSLocalizedString("CoreDataTaskSelectionCompleted", comment: "Completed")
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
