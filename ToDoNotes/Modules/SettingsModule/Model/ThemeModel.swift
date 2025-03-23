//
//  ThemeModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

enum Theme: String, CaseIterable {
    case systemDefault = "Default"
    case light = "Light"
    case dark = "Dark"
    
    static internal var allCases: [Theme] {
        [.light, .dark, .systemDefault]
    }
    
    internal var name: String {
        switch self {
        case .systemDefault:
            Texts.Settings.Appearance.system
        case .light:
            Texts.Settings.Appearance.light
        case .dark:
            Texts.Settings.Appearance.dark
        }
    }
    
    internal var userInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .systemDefault:
                return .unspecified
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
    
    internal var colorScheme: ColorScheme? {
        switch self {
        case .systemDefault:
            nil
        case .light:
            ColorScheme.light
        case .dark:
            ColorScheme.dark
        }
    }
}
