//
//  Labels.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import Foundation

final class Texts {
    
    // MARK: - App Info
    
    enum AppInfo {
        static let title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Planzo"
    }
    
    // MARK: - Onboarding Module Texts
    
    enum OnboardingPage {
        static let skip = NSLocalizedString("OnboardingPageSkip", comment: "Skip")
        static let next = NSLocalizedString("OnboardingPageNext", comment: "Next")
        static let start = NSLocalizedString("OnboardingPageStart", comment: "Start")
        
        static let firstTitle = NSLocalizedString("OnboardingPageFirstTitle", comment: "Here's a short guide to help you get started")
        static let secondTitle = NSLocalizedString("OnboardingPageSecondTitle", comment: "Check tasks by status. Create folders to sort things your way. Notes match folder colors")
        static let thirdTitle = NSLocalizedString("OnboardingPageThirdTitle", comment: "Create notes or tasks with due dates and reminders")
        static let fourthTitle = NSLocalizedString("OnboardingPageFourthTitle", comment: "Swipe tasks left or right for quick actions")
        static let placeholderContent = NSLocalizedString("OnboardingPagePlaceholderContent", comment: "Here's a little guide to help you get started.")
        
        static let markdownTerms = NSLocalizedString("OnboardingPageMarkdownTerms", comment: "By clicking Start, you agree to our [Terms of Service](https://avoqode.com/terms-of-service) and [Privacy Policy](https://avoqode.com/privacy-policy).")
        static let markdownTermsError = NSLocalizedString("OnboardingPageMarkdownTermsError", comment: "Error parsing Terms of Service and Privacy Policy")
    }
    
    // MARK: - Main Module Texts
    
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
    }
    
    // MARK: - Today Module Texts
    
    enum TodayPage {
        static let title = NSLocalizedString("TodayPageTitle", comment: "Today")
        static let placeholder = NSLocalizedString("TodayPagePlaceholder", comment: "No notes for today")
        static let notCompleted = NSLocalizedString("TodayPageActive", comment: "Active")
        static let completed = NSLocalizedString("TodayPageCompleted", comment: "Completed")
    }
    
    // MARK: - Calendar Module Texts
    
    enum CalendarPage {
        static let title = NSLocalizedString("CalendarPageCalendarTitle", comment: "Calendar")
        static let today = NSLocalizedString("CalendarPageCalendarToday", comment: "Today")
        static let emptyList = NSLocalizedString("CalendarPageCalendarEmptyList", comment: "Free day")
        static let accept = NSLocalizedString("CalendarPageCalendarAccept", comment: "Accept")
        static let close = NSLocalizedString("CalendarPageCalendarClose", comment: "Close")
    }
    
    // MARK: - Settings Module Texts
    
    enum Settings {
        static let title = NSLocalizedString("SettingsPageTitle", comment: "Settings")
        static let cancel = NSLocalizedString("SettingsPageCancel", comment: "Cancel")
        static let accept = NSLocalizedString("SettingsPageAccept", comment: "Accept")
        static let ok = NSLocalizedString("SettingsPageOk", comment: "OK")
        static let hide = NSLocalizedString("SettingsPageHide", comment: "Hide")
        
        enum Sync {
            static let title = NSLocalizedString("SettingsPageSyncTitle", comment: "Sync")
            static let off = NSLocalizedString("SettingsPageSyncOff", comment: "Off")
            static let now = NSLocalizedString("SettingsPageSyncNow", comment: "Now")
            static let update = NSLocalizedString("SettingsPageSyncUpdate", comment: "Update")
            static let updating = NSLocalizedString("SettingsPageSyncUpdating", comment: "Updating")
            static let lastSync = NSLocalizedString("SettingsPageSyncLastSync", comment: "Last sync")
            static let disabled = NSLocalizedString("SettingsPageSyncDisabled", comment: "Sync disabled")
            
            static let support = NSLocalizedString("SettingsPageSyncSupport", comment: "If you have any other questions or suggestions, you can [contact us](https://avoqode.com/#contacts).")
            static let supportError = NSLocalizedString("SettingsPageSyncSupportError", comment: "Please, visit our avoqode.com to contact us.")
            
            static let login = NSLocalizedString("SettingsPageSyncLogin", comment: "Sign in to your Planzo account so your tasks sync across all devices and stay protected from loss.")
            static let questions = NSLocalizedString("SettingsPageSyncQuestions", comment: "FAQ")
            
            enum FAQ {
                static let title = NSLocalizedString("SettingsPageSyncFAQTitle", comment: "Unable to sync tasks successfully")
                static let first = NSLocalizedString("SettingsPageSyncFAQFirst", comment: "Our app supports data synchronization across different iOS devices.")
                static let second = NSLocalizedString("SettingsPageSyncFAQSecond", comment: "Update all your devices to the latest version.")
                static let third = NSLocalizedString("SettingsPageSyncFAQThird", comment: "Make sure both devices have a stable Internet connection.")
                static let fourth = NSLocalizedString("SettingsPageSyncFAQFourth", comment: "Make sure both devices are signed in with the same account.")
                static let fifth = NSLocalizedString("SettingsPageSyncFAQFifth", comment: "Make sure you have enough iCloud storage space.")
            }
            
            enum SubFAQ {
                static let title = NSLocalizedString("SettingsPageSyncSubFAQTitle", comment: "Subscription Management")
                static let first = NSLocalizedString("SettingsPageSyncSubFAQFirst", comment: "Our app uses App Store subscriptions. Payment and subscription management are handled through the Apple ID used to purchase it.")
                static let second = NSLocalizedString("SettingsPageSyncSubFAQSecond", comment: "Make sure you are signed in on this device with the same Apple ID you used when purchasing the subscription.")
                static let third = NSLocalizedString("SettingsPageSyncSubFAQThird", comment: "In the app settings, tap “Restore Purchases” to retrieve your active subscription from the App Store.")
                static let fourth = NSLocalizedString("SettingsPageSyncSubFAQFourth", comment: "Check your subscription status in iOS: Settings → your name → Subscriptions. If the subscription was canceled or expired, please renew it.")
                static let fifth = NSLocalizedString("SettingsPageSyncSubFAQFifth", comment: "Ensure that your Apple ID has a valid payment method attached and that there are no purchase restrictions on the account.")
            }
            
            enum Retry {
                static let details = NSLocalizedString("SettingsPageSyncRetry", comment: "Sync error. Tap to try again.")
                static let title = NSLocalizedString("SettingsPageSyncRetryTitle", comment: "Sync error")
                static let content = NSLocalizedString("SettingsPageSyncRetryContent", comment: "Unable to connect to the server. Check your Internet connection.")
                static let tryAgain = NSLocalizedString("SettingsPageSyncRetryTryAgain", comment: "Retry sync")
                static let cancel = NSLocalizedString("SettingsPageSyncRetryCancel", comment: "Cancel")
            }
        }
        
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
        }
        
        enum TimeFormat {
            static let title = NSLocalizedString("SettingsPageTimeLocaleTitle", comment: "Time Format")
            static let twelveHour = NSLocalizedString("SettingsPageTimeLocaleTwelveHour", comment: "12 hour (1:00 PM)")
            static let twentyFourHour = NSLocalizedString("SettingsPageTimeLocaleTwentyFourHour", comment: "24 hour (13:00)")
            static let system = NSLocalizedString("SettingsPageTimeLocaleSystem", comment: "System Default")
        }
        
        enum WeekFirstDay {
            static let title = NSLocalizedString("SettingsPageWeekFirstDayTitle", comment: "Week Start")
            static let monday = NSLocalizedString("SettingsPageWeekFirstDayMonday", comment: "Monday")
            static let tuesday = NSLocalizedString("SettingsPageWeekFirstDayTuesday", comment: "Tuesday")
            static let wednesday = NSLocalizedString("SettingsPageWeekFirstDayWednesday", comment: "Wednesday")
            static let thursday = NSLocalizedString("SettingsPageWeekFirstDayThursday", comment: "Thursday")
            static let friday = NSLocalizedString("SettingsPageWeekFirstDayFriday", comment: "Friday")
            static let saturday = NSLocalizedString("SettingsPageWeekFirstDaySaturday", comment: "Saturday")
            static let sunday = NSLocalizedString("SettingsPageWeekFirstDaySunday", comment: "Sunday")
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
        
        enum Plans {
            static let title = NSLocalizedString("SettingsPagePlansTitle", comment: "Subscription")
            static let free = NSLocalizedString("SettingsPagePlansFree", comment: "Free")
            static let pro = NSLocalizedString("SettingsPagePlansPro", comment: "Pro")
            static let freePlan = NSLocalizedString("SettingsPagePlansFreePlan", comment: "Free Plan")
            static let proPlan = NSLocalizedString("SettingsPagePlansProPlan", comment: "Pro Plan")
            static let error = NSLocalizedString("SettingsPagePlansError", comment: "Unable to retrieve subscription end date")
        }
    }
    
    // MARK: - TaskManagemant Module Texts
    
    enum TaskManagement {
        static let titlePlaceholder = NSLocalizedString("TaskManagementTitlePlaceholder", comment: "What would you like to do?")
        static let previewTitlePlaceholder = NSLocalizedString("TaskManagementTitlePlaceholderPreview", comment: "No title")
        static let descriprionPlaceholder = NSLocalizedString("TaskManagementDescriptionPlaceholder", comment: "Description")
        static let previewDescriprionPlaceholder = NSLocalizedString("TaskManagementDescriptionPlaceholderPreview", comment: "No description")
        static let today = NSLocalizedString("TaskManagementToday", comment: "Today")
        static let target = NSLocalizedString("TaskManagementTarget", comment: "Target")
        static let created = NSLocalizedString("TaskManagementCreated", comment: "Created")
        static let point = NSLocalizedString("TaskManagementPoint", comment: "Point")
        static let addPoint = NSLocalizedString("TaskManagementAddPoint", comment: "Add Point")
        
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
        
        enum SharingAccess {
            static let title = NSLocalizedString("TaskManagementSharingAccessTitle", comment: "Sharing Access Settings")
            static let user = NSLocalizedString("TaskManagementSharingAccessUser", comment: "User")
            static let allowedUsers = NSLocalizedString("TaskManagementSharingAccessAllowedUsers", comment: "Users who have access")
            static let deniedUsers = NSLocalizedString("TaskManagementSharingAccessDeniedUsers", comment: "Access Denied")
            
            static let endSharing = NSLocalizedString("TaskManagementSharingAccessEndSharing", comment: "End Sharing")
            static let shareSetting = NSLocalizedString("TaskManagementSharingAccessShareSetting", comment: "Sharing Settings")
            static let closeAccess = NSLocalizedString("TaskManagementSharingAccessCloseAccess", comment: "Close any access for all")
            
            enum RemoveMeAlert {
                static let title = NSLocalizedString("TaskManagementShareViewRemoveMeTitle", comment: "Remove Access")
                static let message = NSLocalizedString("TaskManagementShareViewRemoveMeMessage", comment: "You will no longer be able to view or edit this note. It will be removed.")
            }
        }
        
        enum ShareView {
            static let title = NSLocalizedString("TaskManagementShareViewTitle", comment: "Collaboration")
            
            static let accessFor = NSLocalizedString("TaskManagementShareViewAccessFor", comment: "Access for")
            
            static let link = NSLocalizedString("TaskManagementShareViewLink", comment: "Share Link")
            static let generating = NSLocalizedString("TaskManagementShareViewGenerating", comment: "Generating Link...")
            
            static let save = NSLocalizedString("TaskManagementShareViewSave", comment: "Save")
            static let cancel = NSLocalizedString("TaskManagementShareViewCancel", comment: "Cancel")
            
            enum Access {
                static let owner = NSLocalizedString("TaskManagementShareViewOwner", comment: "Owner")
                static let view = NSLocalizedString("TaskManagementShareViewView", comment: "Can view")
                static let edit = NSLocalizedString("TaskManagementShareViewEdit", comment: "Can edit")
                static let closeAccess = NSLocalizedString("TaskManagementShareViewCloseAccess", comment: "Close any access")
                
                static let ownerDisctiption = NSLocalizedString("TaskManagementShareViewOwnerDisctiption", comment: "Full access to this note")
                static let viewDisctiption = NSLocalizedString("TaskManagementShareViewViewDisctiption", comment: "You can view this note")
                static let editDescription = NSLocalizedString("TaskManagementShareViewEditDescription", comment: "You can edit this note")
                static let closeDescription = NSLocalizedString("TaskManagementShareViewCloseDescription", comment: "Access Revoked")
            }
            
            enum StopSharingAlert {
                static let title = NSLocalizedString("TaskManagementShareViewStopSharingTitle", comment: "Stop Sharing?")
                static let message = NSLocalizedString("TaskManagementShareViewStopSharingMessage", comment: "All people will lose access to this note and won't be able to view or edit it.")
                static let stop = NSLocalizedString("TaskManagementShareViewStopSharingStop", comment: "Stop")
                
                static let toastTitle = NSLocalizedString("TaskManagementShareViewStopSharingToastTitle", comment: "Sharing ended, returned to folder")
            }
            
            enum DeniedMemberAlert {
                static let title = NSLocalizedString("TaskManagementShareViewDeniedMemberTitle", comment: "Access Revoked")
                static let message = NSLocalizedString("TaskManagementShareViewDeniedMemberMessage", comment: "The user has been removed from this note’s access list.")
                static let ok = NSLocalizedString("TaskManagementShareViewDeniedMemberOk", comment: "OK")
            }
            
            enum RemoveMemberAlert {
                static let title = NSLocalizedString("TaskManagementShareViewRemoveMemberTitle", comment: "Remove Access for")
                static let message = NSLocalizedString("TaskManagementShareViewRemoveMemberMessage", comment: "The user will no longer be able to view or edit this note. To grant access again, you’ll need to share the note once more.")
                static let accept = NSLocalizedString("TaskManagementShareViewRemoveMemberAccept", comment: "Accept")
            }
        }
    }
    
    enum Folders {
        static let title = NSLocalizedString("MainPageFolderTitle", comment: "Folders")
        static let all = NSLocalizedString("MainPageFolderAll", comment: "All")
        static let shared = NSLocalizedString("MainPageFolderShared", comment: "Shared")
        static let reminders = NSLocalizedString("MainPageFolderReminders", comment: "Reminders")
        static let noDate = NSLocalizedString("MainPageFolderNoDate", comment: "No Date")
        static let tasks = NSLocalizedString("MainPageFolderTasks", comment: "Tasks")
        static let lists = NSLocalizedString("MainPageFolderLists", comment: "Lists")
        static let passwords = NSLocalizedString("MainPageFolderPasswords", comment: "Passwords")
        static let other = NSLocalizedString("MainPageFolderOther", comment: "Other")
        
        enum Configure {
            static let title = NSLocalizedString("MainPageFolderConfigureTitle", comment: "Configure")
            static let fullTitle = NSLocalizedString("MainPageFolderConfigureFullTitle", comment: "Configure Folders")
            static let dragAndDrop = NSLocalizedString("MainPageFolderDragAndDrop", comment: "Press and hold to drag & reorder")
            
            static let newFolder = NSLocalizedString("MainPageFolderNewFolder", comment: "New Folder")
            static let create = NSLocalizedString("MainPageFolderCreate", comment: "Create new folder")
            static let delete = NSLocalizedString("MainPageFolderDelete", comment: "Delete folder")
            
            static let save = NSLocalizedString("MainPageFolderSave", comment: "Save")
            static let cancel = NSLocalizedString("MainPageFolderCancel", comment: "Cancel")
            static let changeName = NSLocalizedString("MainPageFolderChangeName", comment: "Change Name")
        }
        
        enum Params {
            static let name = NSLocalizedString("MainPageFolderName", comment: "Name")
            static let color = NSLocalizedString("MainPageFolderColor", comment: "Color")
            static let lock = NSLocalizedString("MainPageFolderLock", comment: "Lock Folder")
            static let lockDescription = NSLocalizedString("MainPageFolderLockDescription", comment: "Requires Face ID or passcode to open")
            static let visibility = NSLocalizedString("MainPageFolderVisibility", comment: "Visibile")
            static let visibilityDescription = NSLocalizedString("MainPageFolderVisibilityDescription", comment: "Visibility mode on the main page")
        }
    }
    
    // MARK: - Search Bar Module Texts
    
    enum SearchBar {
        static let placeholder = NSLocalizedString("SearchBarPlaceholder", comment: "Search by text, title")
        static let cancel = NSLocalizedString("SearchBarCancel", comment: "Cancel")
    }
    
    // MARK: - Tab Bar Module Texts
    
    enum Tabbar {
        static let main = NSLocalizedString("TabbarMainTitle", comment: "Home")
        static let today = NSLocalizedString("TabbarTodayTitle", comment: "Today")
        static let calendar = NSLocalizedString("TabbarCalendarTitle", comment: "Calendar")
        static let settings = NSLocalizedString("TabbarSettingsTitle", comment: "Settings")
    }
    
    enum Authorization {
        static let title = NSLocalizedString("AuthorizationTitle", comment: "Authorization")
        static let login = NSLocalizedString("AuthorizationLogin", comment: "Sign in or Sign up")
        static let logout = NSLocalizedString("AuthorizationLogout", comment: "Log Out")
        static let confirm = NSLocalizedString("AuthorizationConfirm", comment: "Confirm")
        static let confirmLogout = NSLocalizedString("AuthorizationConfirmLogout", comment: "Are you sure you want to log out?")

        static let appleLogin = NSLocalizedString("AuthorizationAppleLogin", comment: "Sign in with Apple")
        static let googleLogin = NSLocalizedString("AuthorizationGoogleLogin", comment: "Sign in with Google")
        static let withoutAuth = NSLocalizedString("AuthorizationWithoutAuth", comment: "Without Authorization")
        
        static let termsOfService = NSLocalizedString("AuthorizationTermsOfService", comment: "Terms of Service")
        static let privacyPolicy = NSLocalizedString("AuthorizationPrivacyPolicy", comment: "Privacy Policy")
        
        enum Details {
            static let account = NSLocalizedString("AuthorizationDetailsAccount", comment: "Account")
            static let nickname = NSLocalizedString("AuthorizationDetailsNickname", comment: "Nickname")
            static let email = NSLocalizedString("AuthorizationDetailsEmail", comment: "Email")
            static let passkey = NSLocalizedString("AuthorizationDetailsPasskey", comment: "Passkey")
            static let twoStepVerification = NSLocalizedString("AuthorizationDetailsTwoStepVerification", comment: "2-Step Verification")
        }
        
        enum Error {
            static let authorizationFailed = NSLocalizedString("AuthorizationFailed", comment: "Authorization failed")
            static let retryLater = NSLocalizedString("AuthorizationRetryLater", comment: "Please try again later")
        }
    }
    
    enum Subscription {
        static let plan = NSLocalizedString("SubscriptionPlan", comment: "Plan")
        static let annual = NSLocalizedString("SubscriptionAnnual", comment: "Annual Plan")
        static let monthly = NSLocalizedString("SubscriptionMonthly", comment: "Monthly Plan")

        enum SubType {
            static let free = NSLocalizedString("SubscriptionFree", comment: "Free")
            static let freePlan = NSLocalizedString("SubscriptionFreePlan", comment: "Free Plan")
            
            static let pro = NSLocalizedString("SubscriptionPro", comment: "Pro")
            static let proPlan = NSLocalizedString("SubscriptionProPlan", comment: "Pro Plan")
        }
        
        enum Benefits {
            static let firstTitle = NSLocalizedString("SubscriptionBenefitsFirstTitle", comment: "Collaborate with Planzo Pro")
            static let firstDescription = NSLocalizedString("SubscriptionBenefitsFirstDescription", comment: "Share tasks with friends and family.")
            static let secondTitle = NSLocalizedString("SubscriptionBenefitsSecondTitle", comment: "Collaborate with Planzo Pro")
            static let secondDescription = NSLocalizedString("SubscriptionBenefitsSecondDescription", comment: "Grant view-only or editing access.")
            static let thirdTitle = NSLocalizedString("SubscriptionBenefitsThirdTitle", comment: "Manage Members")
            static let thirdDescription = NSLocalizedString("SubscriptionBenefitsThirdDescription", comment: "Monitor and change member access.")
            static let fourthTitle = NSLocalizedString("SubscriptionBenefitsFourthTitle", comment: "Special Folder")
            static let fourthDescription = NSLocalizedString("SubscriptionBenefitsFourthDescription", comment: "Shared tasks are stored in a separate folder.")
        }
        
        enum Page {
            static let choosePlan = NSLocalizedString("SubscriptionPageChoosePlanTitle", comment: "Choose your Plan")
            static let continueButton = NSLocalizedString("SubscriptionPageContinueButton", comment: "Continue")
            static let trialContinue = NSLocalizedString("SubscriptionPageTrialContinueButton", comment: "Get 7-day trial")
            static let restore = NSLocalizedString("SubscriptionPageRestoreButton", comment: "Restore purchases")
            
            static let trial = NSLocalizedString("SubscriptionPageTrialTitle", comment: "Get 7 days free with an annual subscription.")
            static let save = NSLocalizedString("SubscriptionPageSaveButton", comment: "Save")
            static let month = NSLocalizedString("SubscriptionPageMonth", comment: "Month")
        }
        
        enum Promo {
            static let title = NSLocalizedString("SubscriptionPromoTitle", comment: "Upgrade to Planzo")
            static let pro = NSLocalizedString("SubscriptionPromoPro", comment: "Pro")
            static let description = NSLocalizedString("SubscriptionPromoDescription", comment: "Share tasks, customize your calendar, track progress, and more.")
        }
        
        enum State {
            static let until = NSLocalizedString("SubscriptionPromoUntil", comment: "Subscription is active until")
            static let untilWithoutDate = NSLocalizedString("SubscriptionPromoUntilWithoutDate", comment: "Subscription is active")
            static let restored = NSLocalizedString("SubscriptionPromoRestored", comment: "Purchases restored successfully.")
        }
        
        enum Error {
            static let purchaceCancelled = NSLocalizedString("SubscriptionErrorPurchaceCancelled", comment: "The purchase was cancelled.")
            static let invalidOffer = NSLocalizedString("SubscriptionErrorInvalidOffer", comment: "The purchase was invalid.")
            static let verificationFailed = NSLocalizedString("SubscriptionErrorVerificationFailed", comment: "The purchase could not be verified.")
            static let unknown = NSLocalizedString("SubscriptionErrorUnknown", comment: "An unknown error occurred.")
        }
    }
    
    // MARK: - Toasts Module Texts
    
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
        
        static let changedFolder = NSLocalizedString("ToastsChangedFolder", comment: "Moved to")
        static let sameFolders = NSLocalizedString("ToastsSameFolders", comment: "Already in this folder")
    }
    
    // MARK: - Tips Module Texts
    
    enum Tips {
        static let mainPageOverviewTitle = NSLocalizedString("TipsMainPageOverviewTitle", comment: "Home Page")
        static let mainPageOverviewContent = NSLocalizedString("TipsMainPageOverviewContent", comment: "Keep track of all your tasks organized by filters and grouped into folders.")
        
        static let todayPageOverviewTitle = NSLocalizedString("TipsTodayPageOverviewTitle", comment: "Today Page")
        static let todayPageOverviewContent = NSLocalizedString("TipsTodayPageOverviewContent", comment: "Review your tasks for the current day, categorized by their status.")
        
        static let calendarPageOverviewTitle = NSLocalizedString("TipsCalendarPageOverview", comment: "Calendar Page")
        static let calendarPageOverviewContent = NSLocalizedString("TipsCalendarPageOverviewContent", comment: "Check tasks assigned to any specific day using the interactive calendar.")
    }
    
    // MARK: - Date Parameters Locale
    
    enum DateParameters {
        static let locale = NSLocalizedString("DateParametersLocale", comment: "en_US")
    }
    
    // MARK: - Core Data Texts
    
    enum CoreData {
        static let container = "TaskModel"
        static let entity = "TaskEntity"
        
        enum TaskSection {
            static let pinned = NSLocalizedString("CoreDataTaskSelectionPinned", comment: "Pinned")
            static let active = NSLocalizedString("CoreDataTaskSelectionActive", comment: "Active")
            static let completed = NSLocalizedString("CoreDataTaskSelectionCompleted", comment: "Completed")
        }
    }
    
    // MARK: - UserDefaults Keys
    
    enum UserDefaults {
        static let skipOnboarding = "SkipOnboarding"
        static let addTaskButtonGlow = "AddTaskButtonGlow"
        static let notifications = "NotificationsEnabled"
        static let theme = "UserTheme"
        static let taskCreation = "TaskCreationPage"
        static let timeFormat = "TimeFormat"
        static let firstDayOfWeek = "FirstDayOfWeek"
        static let didCreateDefaultFolders = "DidCreateDefaultFoldersSet"
    }
    
    // MARK: - Namespace ID Keys
    
    enum NamespaceID {
        static let selectedTab = "SelectedTab"
        static let selectedCalendarCell = "SelectedCalendarCell"
        static let selectedCalendarDate = "SelectedCalendarDate"
        static let selectedEntity = "NoSelectedEntity"
        static let floatingButtons = "MainPageFloatingButtons"
        static let subscriptionButton = "SubscriptionButton"
    }
    
    // MARK: - Accessibility Identifier
    
    enum AccessibilityIdentifier {
        static let tabBarShadow = "TabBarShadow"
    }
}
