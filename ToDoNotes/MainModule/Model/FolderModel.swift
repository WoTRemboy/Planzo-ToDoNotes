//
//  FolderModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

enum Folder: CaseIterable {
    case all
    case noDate
    case lists
    case passwords
    
    internal var name: String {
        switch self {
        case .all:
            return Texts.MainPage.Folders.all
        case .noDate:
            return Texts.MainPage.Folders.noDate
        case .lists:
            return Texts.MainPage.Folders.purchases
        case .passwords:
            return Texts.MainPage.Folders.passwords
        }
    }
    
    internal var lockedIcon: Image {
        switch self {
        case .all:
            Image.Folder.unlocked
        case .noDate:
            Image.Folder.unlocked
        case .lists:
            Image.Folder.unlocked
        case .passwords:
            Image.Folder.locked
        }
    }
    
    internal var color: Color {
        switch self {
        case .all:
            Color.FolderColors.all
        case .noDate:
            Color.FolderColors.noDate
        case .lists:
            Color.FolderColors.lists
        case .passwords:
            Color.FolderColors.passwords
        }
    }
}
