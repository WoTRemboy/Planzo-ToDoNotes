//
//  CustomNavBarPreferenceKeys.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/1/25.
//

import SwiftUI

/// A `PreferenceKey` for passing a custom navigation bar title through the view hierarchy.
struct CustomNavBarTitlePreferenceKey: PreferenceKey {
    
    /// The default value for the title preference key.
    static var defaultValue: String = String()
    
    /// Combines multiple values into a single value.
    /// - Parameters:
    ///   - value: The current accumulated value.
    ///   - nextValue: A closure returning the next value to incorporate.
    static func reduce(value: inout String, nextValue: () -> String) {
        // Always takes the most recent value for the title.
        value = nextValue()
    }
}

/// A `PreferenceKey` for indicating whether a custom navigation bar back button should be shown.
struct CustomNavBarBackButtonPreferenceKey: PreferenceKey {
    
    /// The default value for the back button preference key.
    static var defaultValue: Bool = false
    
    /// Combines multiple values into a single value.
    /// - Parameters:
    ///   - value: The current accumulated value.
    ///   - nextValue: A closure returning the next value to incorporate.
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        // Always takes the most recent value for the back button visibility.
        value = nextValue()
    }
}

/// A `PreferenceKey` for indicating whether a custom navigation bar back button should be shown.
struct CustomNavTitlePositionPreferenceKey: PreferenceKey {
    
    /// The default value for the back button preference key.
    static var defaultValue: NavTitlePosition = .leading
    
    /// Combines multiple values into a single value.
    /// - Parameters:
    ///   - value: The current accumulated value.
    ///   - nextValue: A closure returning the next value to incorporate.
    static func reduce(value: inout NavTitlePosition, nextValue: () -> NavTitlePosition) {
        // Always takes the most recent value for the back button visibility.
        value = nextValue()
    }
}

// MARK: - View Extension for Custom Navigation Items

extension View {
    
    /// Sets the custom navigation bar title for the view.
    /// - Parameter title: A `String` representing the navigation bar title.
    /// - Returns: A modified view that applies the title preference.
    private func customNavigationTitle(_ title: String) -> some View {
        // Passes the custom title up the view hierarchy using the preference key.
        preference(key: CustomNavBarTitlePreferenceKey.self, value: title)
    }
    
    /// Sets whether a custom back button should be displayed in the navigation bar.
    /// - Parameter show: A `Bool` value indicating if the back button should be shown.
    /// - Returns: A modified view that applies the back button preference.
    private func customNavigationBackButton(_ show: Bool) -> some View {
        // Passes the back button visibility up the view hierarchy using the preference key.
        preference(key: CustomNavBarBackButtonPreferenceKey.self, value: show)
    }
    
    private func customNavigationTitlePosition(_ show: NavTitlePosition) -> some View {
        // Passes the back button visibility up the view hierarchy using the preference key.
        preference(key: CustomNavTitlePositionPreferenceKey.self, value: show)
    }
    
    /// Sets both the custom navigation title and back button visibility.
    /// - Parameters:
    ///   - title: A `String` for the navigation bar title (default is an empty string).
    ///   - showBackButton: A `Bool` indicating whether the back button should be shown (default is `false`).
    /// - Returns: A modified view that applies both preferences.
    internal func customNavBarItems(title: String = String(), showBackButton: Bool = false, position: NavTitlePosition = .leading) -> some View {
        // Applies both the custom title and back button preferences.
        self
            .customNavigationTitle(title)
            .customNavigationBackButton(showBackButton)
            .customNavigationTitlePosition(position)
    }
}
