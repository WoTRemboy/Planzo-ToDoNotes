//
//  TabItems.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

/// A utility struct providing configured tab items for the main tab bar.
struct TabItems {
    
    /// Creates the main tab view.
    /// - Parameter isSelected: A boolean indicating whether the tab is currently selected.
    /// - Returns: A `MainView` wrapped in a tab item.
    static func mainTab(isSelected: Bool) -> some View {
        MainView()
            .tabItem {
                isSelected ? Image.TabBar.Selected.home : Image.TabBar.Unselected.home
                    .renderingMode(.template)
                Text(Texts.Tabbar.main)
            }
    }
    
    /// Creates the today tab view.
    /// - Parameter isSelected: A boolean indicating whether the tab is currently selected.
    /// - Returns: A `TodayView` wrapped in a tab item.
    static func todayTab(isSelected: Bool) -> some View {
        let todayDay = Date.todayDay
        return TodayView()
            .tabItem {
                isSelected ? Image.TabBar.Selected.today(for: todayDay) : Image.TabBar.Unselected.today(for: todayDay)
                    .renderingMode(.template)
                Text(Texts.Tabbar.today)
            }
    }
    
    /// Creates the calendar tab view.
    /// - Parameter isSelected: A boolean indicating whether the tab is currently selected.
    /// - Returns: A `CalendarView` wrapped in a tab item.
    static func calendarTab(isSelected: Bool) -> some View {
        CalendarView()
            .tabItem {
                isSelected ? Image.TabBar.Selected.calendar : Image.TabBar.Unselected.calendar
                    .renderingMode(.template)
                Text(Texts.Tabbar.calendar)
            }
    }
    
    /// Creates the settings tab view.
    /// - Parameters:
    ///   - isSelected: A boolean indicating whether the tab is currently selected.
    ///   - networkService: An instance of `AuthNetworkService` required for settings.
    /// - Returns: A `SettingsView` wrapped in a tab item.
    static func settingsTab(isSelected: Bool, networkService: AuthNetworkService) -> some View {
        SettingsView(networkService: networkService)
            .tabItem {
                isSelected ? Image.TabBar.Selected.settings : Image.TabBar.Unselected.settings
                    .renderingMode(.template)
                Text(Texts.Tabbar.settings)
            }
    }
}

