//
//  TabItems.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct TabItems {
    static func mainTab(isSelected: Bool) -> some View {
        MainView()
            .environmentObject(MainViewModel())
            .tabItem {
                isSelected ? Image.TabBar.Selected.home : Image.TabBar.Unselected.home
                    .renderingMode(.template)
                Text(Texts.Tabbar.main)
            }
    }
    
    static func todayTab(isSelected: Bool) -> some View {
        TodayView()
            .environmentObject(TodayViewModel())
            .tabItem {
                isSelected ? Image.TabBar.Selected.today : Image.TabBar.Unselected.today
                    .renderingMode(.template)
                Text(Texts.Tabbar.today)
            }
    }
    
    static func calendarTab(isSelected: Bool) -> some View {
        CalendarView()
            .environmentObject(CalendarViewModel())
            .tabItem {
                isSelected ? Image.TabBar.Selected.calendar : Image.TabBar.Unselected.calendar
                    .renderingMode(.template)
                Text(Texts.Tabbar.calendar)
            }
    }
    
    static func settingsTab(isSelected: Bool) -> some View {
        let defaults = UserDefaults.standard
        let rawValue = defaults.string(forKey: Texts.UserDefaults.notifications) ?? String()
        let notificationsStatus = NotificationStatus(rawValue: rawValue) ?? .prohibited
        
        return SettingsView()
            .environmentObject(SettingsViewModel(
                notificationsEnabled: notificationsStatus == .allowed))
            .tabItem {
                isSelected ? Image.TabBar.Selected.settings : Image.TabBar.Unselected.settings
                    .renderingMode(.template)
                Text(Texts.Tabbar.settings)
            }
    }
}
