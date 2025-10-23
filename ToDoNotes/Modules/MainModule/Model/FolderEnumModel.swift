//
//  FolderEnumModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

/// Represents predefined task folders used for categorizing tasks.
enum FolderEnum: String, CaseIterable {
    case all = "TaskFoldersAll"
    case reminders = "TaskFoldersReminders"
    case tasks = "TaskFoldersTasks"
    case lists = "TaskFoldersLists"
    case other = "TaskFoldersNoDate"
    
    /// Returns a localized name for each folder to display in the UI.
    internal var name: String {
        switch self {
        case .all:
            return Texts.Folders.all
        case .reminders:
            return Texts.Folders.reminders
        case .tasks:
            return Texts.Folders.tasks
        case .lists:
            return Texts.Folders.purchases
        case .other:
            return Texts.Folders.other
        }
    }
    
    /// Returns the icon associated with the folder.
    internal var lockedIcon: Image {
        switch self {
        case .all, .reminders, .tasks, .lists, .other:
            Image.Folder.unlocked
        }
    }
    
    /// Returns a specific color associated with the folder for UI styling.
    internal var color: Color {
        switch self {
        case .all:
            Color.FolderColors.all
        case .reminders:
            Color.FolderColors.reminders
        case .tasks:
            Color.FolderColors.tasks
        case .lists:
            Color.FolderColors.lists
        case .other:
            Color.FolderColors.other
        }
    }
}
