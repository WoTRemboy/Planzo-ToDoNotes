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
    case lists = "TaskFoldersLists"
    case noDate = "TaskFoldersNoDate"
    
    internal var name: String {
        switch self {
        case .all:
            return Texts.MainPage.Folders.all
        case .reminders:
            return Texts.MainPage.Folders.reminders
        case .lists:
            return Texts.MainPage.Folders.purchases
        case .noDate:
            return Texts.MainPage.Folders.noDate
        }
    }
    
    internal var lockedIcon: Image {
        switch self {
        case .all:
            Image.Folder.unlocked
        case .reminders:
            Image.Folder.unlocked
        case .lists:
            Image.Folder.unlocked
        case .noDate:
            Image.Folder.unlocked
        }
    }
    
    internal var color: Color {
        switch self {
        case .all:
            Color.FolderColors.all
        case .reminders:
            Color.FolderColors.reminders
        case .lists:
            Color.FolderColors.lists
        case .noDate:
            Color.FolderColors.noDate
        }
    }
}
