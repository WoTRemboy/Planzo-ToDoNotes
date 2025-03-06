//
//  ImageExtension.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI

extension Image {
    enum Placeholder {
        static let previewIcon = Image("PlaceholderPreviewIcon")
        static let tabbarIcon = Image("PlaceholderTabbarIcon")
    }
    
    enum NavigationBar {
        enum MainTodayPages {
            static let importantSelect = Image("NavIconSelectImportant")
            static let importantDeselect = Image("NavIconDeselectImportant")
        }
        
        static let search = Image("NavIconSearch")
        static let favorites = Image("NavIconFavorites")
        static let calendar = Image("NavIconCalendar")
        static let more = Image("NavIconMore")
        static let hide = Image("NavIconHide")
        static let back = Image("NavIconBack")
        static let share = Image("NavIconShare")
    }
    
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
    
    enum Folder {
        static let navBar = Image("FoldersNavIcon")
        static let locked = Image("FolderLockIcon")
        static let unlocked = Image("FolderUnlockIcon")
    }
    
    enum Settings {
        static let about = Image("SettingsAboutApp")
        static let aboutLogo = Image("SettingsAboutAppLogo")
        static let appearance = Image("SettingsAppearance")
        static let language = Image("SettingsLanguage")
        static let notifications = Image("SettingsNotification")
        static let reset = Image("SettingsReset")
        static let email = Image("SettingsEmail")
        static let taskCreate = Image("SettingsTaskCreate")
        
        static let chevron = Image("SettingsChevron")
        static let check = Image(systemName: "checkmark")
        
        enum TaskCreate {
            static let popup = Image("TaskCreationPopup")
            static let fullScreen = Image("TaskCreationFullScreen")
        }
    }
    
    enum Selector {
        static let selected = Image("SelectorSelected")
        static let unselected = Image("SelectorUnselected")
    }
    
    enum TaskManagement {
        static let plus = Image("AddPlusIcon")
        static let emptyList = Image("EmptyTaskList")
        static let scrollToTop = Image("ScrollToTopIcon")
        static let scrollToBottom = Image("ScrollToBottomIcon")
        
        enum EditTask {
            static let calendar = Image("EditTaskCalendar")
            static let check = Image("EditTaskCheck")
            static let uncheck = Image("EditTaskUncheck")
            static let more = Image("EditTaskMore")
            static let accept = Image("EditTaskAccept")
            static let ready = Image("EditTaskReady")
            static let link = Image("EditTaskLink")
            
            static let checkListCheck = Image("ChecklistItemChecked")
            static let checkListUncheck = Image("ChecklistItemUnchecked")
            
            enum Menu {
                static let completed = Image("EditTaskCompletedOffIcon")
                static let completedDeselect = Image("EditTaskCompletedOnIcon")
                
                static let importantSelect = Image("EditTaskImportantOffIcon")
                static let importantDeselect = Image("EditTaskImportantOnIcon")
                
                static let pinnedSelect = Image("EditTaskPinnedOffIcon")
                static let pinnedDeselect = Image("EditTaskPinnedOnIcon")
                
                static let copy = Image("EditTaskCopyIcon")
                static let trash = Image("EditTaskTrashIcon")
            }
        }
        
        enum TaskRow {
            static let uncheckedBox = Image("TaskRowUncheckedBox")
            static let checkedBox = Image("TaskRowCheckedBox")
            
            static let pinned = Image("TaskRowPinned")
            static let reminder = Image("TaskRowRemainder")
            static let content = Image("TaskRowContent")
            static let important = Image("TaskRowImportant")
            static let expired = Image("TaskRowExpired")
            
            enum SwipeAction {
                static let important = Image("TaskRowSwipeImportantOff")
                static let importantDeselect = Image("TaskRowSwipeImportantOn")
                
                static let pinned = Image("TaskRowSwipePinnedOff")
                static let pinnedDeselect = Image("TaskRowSwipePinnedOn")
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
    
    enum LoginPage {
        static let appleLogo = Image("AppleLogo")
        static let googleLogo = Image("GoogleLogo")
    }
}
