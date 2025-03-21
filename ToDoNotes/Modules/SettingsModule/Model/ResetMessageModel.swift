//
//  ResetMessageModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/6/25.
//

enum ResetMessage {
    case success
    case failure
    case empty
    
    internal var title: String {
        switch self {
        case .success:
            Texts.Settings.Reset.success
        case .failure:
            Texts.Settings.Reset.failure
        case .empty:
            Texts.Settings.Reset.empty
        }
    }
    
    internal var message: String {
        switch self {
        case .success:
            Texts.Settings.Reset.successMessage
        case .failure:
            Texts.Settings.Reset.failureMessage
        case .empty:
            Texts.Settings.Reset.emptyMessage
        }
    }
}
