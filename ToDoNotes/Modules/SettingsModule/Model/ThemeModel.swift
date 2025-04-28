//
//  ThemeModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

/// Represents the available appearance themes for the application.
enum Theme: String, CaseIterable {
    
    // MARK: - Cases
    
    /// Follow the system's appearance (default).
    case systemDefault = "Default"
    /// Always use the light mode.
    case light = "Light"
    /// Always use the dark mode.
    case dark = "Dark"
    
    // MARK: - All Cases (Custom Order)
    
    /// Returns all available themes in a custom order for UI pickers.
    static internal var allCases: [Theme] {
        [.light, .dark, .systemDefault]
    }
    
    // MARK: - Properties
    
    /// Returns the localized display name for the theme.
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
    
    /// Returns the corresponding `UIUserInterfaceStyle` for views.
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
    
    /// Returns the corresponding `ColorScheme` for views.
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
