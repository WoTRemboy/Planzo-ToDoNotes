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
        static let search = Image("SearchNavIcon")
        static let favorites = Image("FavoritesNavIcon")
        static let calendar = Image("CalendarNavIcon")
        static let more = Image("MoreNavIcon")
        static let back = Image("BackNavIcon")
        static let share = Image("ShareNavIcon")
    }
    
    enum Folder {
        static let navBar = Image("FoldersNavIcon")
        static let locked = Image("FolderLockIcon")
        static let unlocked = Image("FolderUnlockIcon")
    }
    
    enum Settings {
        static let about = Image("SettingsAboutApp")
        static let appearance = Image("SettingsAppearance")
        static let language = Image("SettingsLanguage")
        static let email = Image("SettingsEmail")
        
        static let chevron = Image(systemName: "chevron.right")
        static let check = Image(systemName: "checkmark")
    }
    
    enum TaskManagement {
        static let plus = Image("AddPlusIcon")
        static let emptyList = Image("EmptyTaskList")
        
        enum EditTask {
            static let calendar = Image("EditTaskCalendar")
            static let check = Image("EditTaskCheck")
            static let uncheck = Image("EditTaskUncheck")
            static let more = Image("EditTaskMore")
            static let accept = Image("EditTaskAccept")
            static let link = Image("EditTaskLink")
            
            static let checkListCheck = Image("ChecklistItemChecked")
            static let checkListUncheck = Image("ChecklistItemUnchecked")
        }
        
        enum TaskRow {
            static let uncheckedBox = Image("TaskRowUncheckedBox")
            static let checkedBox = Image("TaskRowCheckedBox")
        }
    }
    
    enum LoginPage {
        static let appleLogo = Image("AppleLogo")
        static let googleLogo = Image("GoogleLogo")
    }
}
