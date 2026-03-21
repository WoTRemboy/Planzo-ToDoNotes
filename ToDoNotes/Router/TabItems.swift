//
//  TabItems.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI
import UIKit

/// A utility struct providing configured tab items for the main tab bar.
struct TabItems {
    
    /// Creates the main tab view.
    /// - Parameter isSelected: A boolean indicating whether the tab is currently selected.
    /// - Returns: A `MainView` wrapped in a tab item.
    static func mainTab(isSelected: Bool) -> some View {
        MainTabRoot()
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
        return TodayTabRoot()
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
        CalendarTabRoot()
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
        SettingsTabRoot(networkService: networkService)
            .tabItem {
                isSelected ? Image.TabBar.Selected.settings : Image.TabBar.Unselected.settings
                    .renderingMode(.template)
                Text(Texts.Tabbar.settings)
            }
    }
}

private struct MainTabRoot: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var useIPadLayout: Bool {
        UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular
    }

    var body: some View {
        if useIPadLayout {
            MainViewIPad()
        } else {
            MainView()
        }
    }
}

private struct TodayTabRoot: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var useIPadLayout: Bool {
        UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular
    }

    var body: some View {
        if useIPadLayout {
            TodayViewIPad()
        } else {
            TodayView()
        }
    }
}

private struct CalendarTabRoot: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var useIPadLayout: Bool {
        UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular
    }

    var body: some View {
        if useIPadLayout {
            CalendarViewIPad()
        } else {
            CalendarView()
        }
    }
}

private struct SettingsTabRoot: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let networkService: AuthNetworkService

    private var useIPadLayout: Bool {
        UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular
    }

    var body: some View {
        if useIPadLayout {
            SettingsViewIPad(networkService: networkService)
        } else {
            SettingsView(networkService: networkService)
        }
    }
}

