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
    }
    
    enum Folder {
        static let navBar = Image("FoldersNavIcon")
        static let locked = Image("FolderLockIcon")
        static let unlocked = Image("FolderUnlockIcon")
    }
    
    enum Settings {
        static let about = Image("SettingsAboutApp")
    }
    
    enum TaskManagement {
        static let plus = Image("AddPlusIcon")
    }
}
