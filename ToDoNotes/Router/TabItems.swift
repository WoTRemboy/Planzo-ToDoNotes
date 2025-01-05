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
            .tabItem {
                Image.Placeholder.tabbarIcon
                    .renderingMode(.template)
                Text(Texts.Tabbar.calendar)
            }
    }
    
    static func settingsTab() -> some View {
        SettingsView()
            .tabItem {
                Image.Placeholder.tabbarIcon
                    .renderingMode(.template)
                Text(Texts.Tabbar.settings)
            }
    }
}
