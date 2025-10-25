//
//  FolderConfigureEnumModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 24/10/2025.
//

import SwiftUI

enum FolderConfig: CaseIterable {
    case name
    case color
    case lock
    case visibility
    
    internal var name: String {
        switch self {
        case .name:
            return Texts.Folders.Params.name
        case .color:
            return Texts.Folders.Params.color
        case .lock:
            return Texts.Folders.Params.lock
        case .visibility:
            return Texts.Folders.Params.visibility
        }
    }
    
    internal var description: String? {
        switch self {
        case .lock:
            return Texts.Folders.Params.lockDescription
        case .visibility:
            return Texts.Folders.Params.visibilityDescription
        default:
            return nil
        }
    }
    
    internal var chevron: Bool {
        switch self {
        case .name, .color:
            return true
        case .lock, .visibility:
            return false
        }
    }
}


enum FolderMethod {
    case create
    case delete
    
    internal var name: String {
        switch self {
        case .create:
            return Texts.Folders.Configure.create
        case .delete:
            return Texts.Folders.Configure.delete
        }
    }
    
    internal var icon: Image? {
        switch self {
        case .create:
            nil
        case .delete:
            Image.Folder.trash
        }
    }
    
    internal var color: Color {
        switch self {
        case .create:
            Color.LabelColors.labelPrimary
        case .delete:
            Color.LabelColors.labelLogout
        }
    }
}
