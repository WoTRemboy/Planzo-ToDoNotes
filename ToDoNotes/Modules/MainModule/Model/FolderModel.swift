//
//  FolderModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

enum Folder: String, CaseIterable {
    case all = "TaskFoldersAll"
    case reminders = "TaskFoldersReminders"
    case tasks = "TaskFoldersTasks"
    case lists = "TaskFoldersLists"
    case other = "TaskFoldersNoDate"
    
    internal var name: String {
        switch self {
        case .all:
            return Texts.MainPage.Folders.all
        case .reminders:
            return Texts.MainPage.Folders.reminders
        case .tasks:
            return Texts.MainPage.Folders.tasks
        case .lists:
            return Texts.MainPage.Folders.purchases
        case .other:
            return Texts.MainPage.Folders.other
        }
    }
    
    internal var lockedIcon: Image {
        switch self {
        case .all, .reminders, .tasks, .lists, .other:
            Image.Folder.unlocked
        }
    }
    
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
