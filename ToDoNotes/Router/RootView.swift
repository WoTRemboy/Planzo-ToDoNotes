//
//  RootView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = TabRouter()
    
    internal var body: some View {
        TabView(selection: $router.selectedTab) {
            TabItems.mainTab(isSelected: router.selectedTab == .main)
                .tag(TabRouter.Tab.main)
            
            TabItems.todayTab(isSelected: router.selectedTab == .today)
                .tag(TabRouter.Tab.today)
            
            TabItems.calendarTab(isSelected: router.selectedTab == .calendar)
                .tag(TabRouter.Tab.calendar)
            
            TabItems.settingsTab(isSelected: router.selectedTab == .settings)
                .tag(TabRouter.Tab.settings)
        }
        .accentColor(Color.LabelColors.labelPrimary)
        .environmentObject(router)
    }
}

#Preview {
    RootView()
        .environmentObject(CoreDataViewModel())
}
