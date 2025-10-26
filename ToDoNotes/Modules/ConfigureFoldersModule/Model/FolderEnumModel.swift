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
    case shared = "TaskFoldersShared"
    case lists = "TaskFoldersLists"
    case tasks = "TaskFoldersTasks"
    case other = "TaskFoldersOther"
    
    /// Returns a localized name for each folder to display in the UI.
    internal var name: String {
        switch self {
        case .all:
            return Texts.Folders.all
        case .shared:
            return Texts.Folders.shared
        case .tasks:
            return Texts.Folders.tasks
        case .lists:
            return Texts.Folders.lists
        case .other:
            return Texts.Folders.other
        }
    }
    
    /// Returns a specific color associated with the folder for UI styling.
    internal var color: Color {
        switch self {
        case .all:
            Color.FolderColors.all
        case .shared:
            Color.FolderColors.shared
        case .tasks:
            Color.FolderColors.tasks
        case .lists:
            Color.FolderColors.lists
        case .other:
            Color.FolderColors.other
        }
    }
    
    internal var system: Bool {
        switch self {
        case .all, .shared:
            return true
        default:
            return false
        }
    }
}
