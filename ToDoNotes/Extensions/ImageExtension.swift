//
//  ImageExtension.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI

extension Image {
    
    // MARK: - Placeholder Images
    
    enum Placeholder {
        static let previewIcon = Image("PlaceholderPreviewIcon")
        static let tabbarIcon = Image("PlaceholderTabbarIcon")
        static let calendarFreeDay = Image("CalendarFreeDay")
    }
    
    // MARK: - Onboarding Images
    
    enum Onboarding {
        static let splashScreenLogo = Image("SplashScreenLogo")
        static let first = Image("OnboardingFirst")
        static let second = Image("OnboardingSecond")
        static let third = Image("OnboardingThird")
        static let fourth = Image("OnboardingFourth")
        static let fifth = Image("OnboardingFifth")
        static let sixth = Image("OnboardingSixth")
    }
    
    // MARK: - Navigation Bar Images
    
    enum NavigationBar {
        enum MainTodayPages {
            static let importantSelect = Image("NavIconSelectImportant")
            static let importantDeselect = Image("NavIconDeselectImportant")
            static let deletedFilter = Image("NavIconFilterDeleted")
        }
        
        enum SearchBar {
            static let glass = Image("SearchBarGlass")
            static let clear = Image("SearchBarClear")
        }
        
        static let search = Image("NavIconSearch")
        static let favorites = Image("NavIconFavorites")
        static let calendar = Image("NavIconCalendar")
        static let more = Image("NavIconMore")
        static let hide = Image("NavIconHide")
        static let back = Image("NavIconBack")
        static let share = Image("NavIconShare")
    }
    
    // MARK: - Tab Bar Images
    
    enum TabBar {
        enum Selected {
            static let home = Image("TabBarIconSelectedHome")
            static let today = Image("TabBarIconSelectedToday")
            static let calendar = Image("TabBarIconSelectedCalendar")
            static let settings = Image("TabBarIconSelectedSettings")
        }
        
        enum Unselected {
            static let home = Image("TabBarIconHome")
            static let today = Image("TabBarIconToday")
            static let calendar = Image("TabBarIconCalendar")
            static let settings = Image("TabBarIconSettings")
        }
    }
    
    // MARK: - Folder Images
    
    enum Folder {
        static let navBar = Image("FoldersNavIcon")
        static let locked = Image("FolderLockIcon")
        static let unlocked = Image("FolderUnlockIcon")
        static let hidden = Image("FolderHiddenIcon")
        static let shared = Image("FolderSharedIcon")
        static let config = Image("FolderConfigIcon")
        static let trash = Image("FolderTrashIcon")
    }
    
    // MARK: - Settings Images
    
    enum Settings {
        static let signIn = Image("SettingsSignIn")
        static let logout = Image("SettingsLogout")
        
        static let about = Image("SettingsAboutApp")
        static let aboutLogo = Image("SettingsAboutAppLogo")
        static let sync = Image("SettingsSync")
        static let appearance = Image("SettingsAppearance")
        static let language = Image("SettingsLanguage")
        static let notifications = Image("SettingsNotification")
        static let reset = Image("SettingsReset")
        static let email = Image("SettingsEmail")
        static let taskCreate = Image("SettingsTaskCreate")
        
        static let timeformat = Image("SettingsTimeFormat")
        static let weekFirstDay = Image("SettingsWeekFirstDay")
        
        static let chevron = Image("SettingsChevron")
        static let check = Image(systemName: "checkmark")
        
        static let syncError = Image("SyncError")
        static let syncUpdating = Image("SyncUpdating")
        
        enum TaskCreate {
            static let popup = Image("TaskCreationPopup")
            static let fullScreen = Image("TaskCreationFullScreen")
        }
    }
    
    // MARK: - Selector Images
    
    enum Selector {
        static let selected = Image("SelectorSelected")
        static let unselected = Image("SelectorUnselected")
        static let bullet = Image("SelectorBullet")
    }
    
    // MARK: - Task Management Images
    
    enum TaskManagement {
        static let plus = Image("AddPlusIcon")
        static let emptyList = Image("EmptyTaskList")
        static let scrollToTop = Image("ScrollToTopIcon")
        static let scrollToBottom = Image("ScrollToBottomIcon")
        
        enum EditTask {
            static let calendar = Image("EditTaskCalendar")
            static let calendarUnselected = Image("EditTaskCalendarUnselected")
            
            static let check = Image("EditTaskCheck")
            static let uncheck = Image("EditTaskUncheck")
            static let more = Image("EditTaskMore")
            static let accept = Image("EditTaskAccept")
            static let ready = Image("EditTaskReady")
            static let link = Image("EditTaskLink")
            
            enum Checklist {
                static let check = Image("ChecklistItemChecked")
                static let uncheck = Image("ChecklistItemUnchecked")
                static let remove = Image("ChecklistItemRemove")
                static let move = Image("ChecklistItemMove")
            }

            enum Menu {
                static let completed = Image("EditTaskCompletedOffIcon")
                static let completedDeselect = Image("EditTaskCompletedOnIcon")
                
                static let importantSelect = Image("EditTaskImportantOffIcon")
                static let importantDeselect = Image("EditTaskImportantOnIcon")
                
                static let pinnedSelect = Image("EditTaskPinnedOffIcon")
                static let pinnedDeselect = Image("EditTaskPinnedOnIcon")
                
                static let shareSettings = Image("EditTaskShareSettingIcon")
                static let closeSharing = Image("EditTaskCloseShareIcon")
                
                static let copy = Image("EditTaskCopyIcon")
                static let trash = Image("EditTaskTrashIcon")
            }
        }
        
        enum TaskRow {
            static let uncheckedBox = Image("TaskRowUncheckedBox")
            static let checkedBox = Image("TaskRowCheckedBox")
            
            static let pinned = Image("TaskRowPinned")
            static let reminderOn = Image("TaskRowReminderOn")
            static let reminderOff = Image("TaskRowReminderOff")
            static let contentOn = Image("TaskRowContentOn")
            static let contentOff = Image("TaskRowContentOff")
            static let important = Image("TaskRowImportant")
            static let expired = Image("TaskRowExpired")
            static let shared = Image("TaskRowShared")
            
            enum SwipeAction {
                static let important = Image("TaskRowSwipeImportantOff")
                static let importantDeselect = Image("TaskRowSwipeImportantOn")
                static let pinned = Image("TaskRowSwipePinnedOff")
                static let pinnedDeselect = Image("TaskRowSwipePinnedOn")
                static let remove = Image("TaskRowSwipeRemove")
                static let restore = Image("TaskRowSwipeRestore")
                static let folder = Image("TaskRowSwipeFolder")
                static let share = Image("TaskRowSwipeShare")
            }
        }
        
        enum DateSelector {
            static let close = Image("TaskDateSelectionClose")
            static let confirm = Image("TaskDateSelectorConfirm")
            static let monthForward = Image("TaskDateSelectorMonthForward")
            static let monthBackward = Image("TaskDateSelectorMonthBackward")
            
            static let time = Image("TaskDateSelectionTimeOff")
            static let timeSelected = Image("TaskDateSelectionTimeOn")
            static let reminder = Image("TaskDateSelectionReminderOff")
            static let reminderSelected = Image("TaskDateSelectionReminderOn")
            static let cycle = Image("TaskDateSelectionCycle")
            
            static let checked = Image("TaskDateSelectionChecked")
            static let unchecked = Image("TaskDateSelectionUnchecked")
            
            static let remove = Image("TaskDateSelectionRemove")
            static let menu = Image("TaskDateSelectionMenu")
        }
    }
    
    enum Subscription {
        static let firstBenefit = Image("SubscriptionBenefitsOne")
        static let secondBenefit = Image("SubscriptionBenefitsTwo")
        static let thirdBenefit = Image("SubscriptionBenefitsThree")
        static let fourthBenefit = Image("SubscriptionBenefitsFour")
        
        static let check = Image("SubscriptionCheck")
        static let premium = Image("SubscriptionPremiumIcon")
    }
    
    // MARK: - Login Page Images
    
    enum LoginPage {
        static let appleLogo = Image("AppleLogo")
        static let googleLogo = Image("GoogleLogo")
    }
}

// MARK: - UIImage Extension

extension UIImage {
    enum TaskManagement {
        static let importantSelect = UIImage(named: "EditTaskImportantOffIcon")
        static let importantDeselect = UIImage(named: "EditTaskImportantOnIcon")
        static let pinnedSelect = UIImage(named: "EditTaskPinnedOffIcon")
        static let pinnedDeselect = UIImage(named: "EditTaskPinnedOnIcon")
        static let copy = UIImage(named: "EditTaskCopyIcon")
        static let trash = UIImage(named: "EditTaskTrashIcon")
    }
}
