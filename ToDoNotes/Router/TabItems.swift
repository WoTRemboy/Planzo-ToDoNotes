//
//  TabItems.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct TabItems {
    static func mainTab() -> some View {
        MainView()
            .environmentObject(MainViewModel())
            .tabItem {
                Image.Placeholder.tabbarIcon
                    .renderingMode(.template)
                Text(Texts.Tabbar.main)
            }
    }
    
    static func todayTab() -> some View {
        TodayView()
            .environmentObject(TodayViewModel())
            .tabItem {
                Image.Placeholder.tabbarIcon
                    .renderingMode(.template)
                Text(Texts.Tabbar.today)
            }
    }
    
    static func calendarTab() -> some View {
        CalendarView()
            .environmentObject(CalendarViewModel())
            .tabItem {
                Image.Placeholder.tabbarIcon
                    .renderingMode(.template)
                Text(Texts.Tabbar.calendar)
            }
    }
    
    static func settingsTab() -> some View {
        let defaults = UserDefaults.standard
        let rawValue = defaults.string(forKey: Texts.UserDefaults.notifications) ?? String()
        let notificationsStatus = NotificationStatus(rawValue: rawValue) ?? .prohibited
        
        return SettingsView()
            .environmentObject(SettingsViewModel(
                notificationsEnabled: notificationsStatus == .allowed))
            .tabItem {
                Image.Placeholder.tabbarIcon
                    .renderingMode(.template)
                Text(Texts.Tabbar.settings)
            }
    }
}
