//
//  FolderModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

enum Folder: CaseIterable {
    case all
    case noDate
    case purchases
    case passwords
    
    internal var name: String {
        switch self {
        case .all:
            return Texts.MainPage.Folders.all
        case .noDate:
            return Texts.MainPage.Folders.noDate
        case .purchases:
            return Texts.MainPage.Folders.purchases
        case .passwords:
            return Texts.MainPage.Folders.passwords
        }
    }
}
