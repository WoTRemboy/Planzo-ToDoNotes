//
//  FAQBulletModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 11/11/2025.
//

enum FAQBullet: CaseIterable {
    case update
    case connection
    case login
    case icloud
    
    internal var title: String {
        switch self {
        case .update:
            return Texts.Settings.Sync.FAQ.second
        case .connection:
            return Texts.Settings.Sync.FAQ.third
        case .login:
            return Texts.Settings.Sync.FAQ.fourth
        case .icloud:
            return Texts.Settings.Sync.FAQ.fifth
        }
    }
}
