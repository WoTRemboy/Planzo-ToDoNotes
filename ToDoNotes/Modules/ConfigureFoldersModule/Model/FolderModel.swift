//
//  FolderModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 23/10/2025.
//

import Foundation
import SwiftUI

// MARK: - Folder & FolderColor Models

struct Folder: Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    var locked: Bool
    var serverId: String
    var system: Bool = false
    var shared: Bool = false
    var visible: Bool
    var color: FolderColor
    var order: Int
    
    internal var localizedName: String {
        if system, !shared {
            return Texts.Folders.all
        } else if system, shared {
            return Texts.Folders.shared
        }
        return name
    }
    
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.id == rhs.id
    }
    
    static func mock(locked: Bool = false, system: Bool = false, shared: Bool = false) -> Folder {
        Folder(
            id: UUID(),
            name: "Test Folder",
            locked: locked,
            serverId: "123",
            system: system,
            shared: shared,
            visible: true,
            color: FolderColor.mock,
            order: 0
        )
    }
}

struct FolderColor: Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    internal func rgbToColor() -> Color {
        Color(red: self.red, green: self.green, blue: self.blue, opacity: self.alpha)
    }
    
    static func colorToRgb(_ color: Color) -> FolderColor {
        let uiColor = UIColor(color)
        return FolderColor(
            red: Double(uiColor.components.red),
            green: Double(uiColor.components.green),
            blue: Double(uiColor.components.blue),
            alpha: Double(uiColor.components.alpha)
        )
    }
    
    static var mock: FolderColor {
        FolderColor(red: 0.5, green: 0.7, blue: 0.3, alpha: 1)
    }
}
