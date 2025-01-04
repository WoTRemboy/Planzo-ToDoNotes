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
            TabItems.mainTab()
                .tag(TabRouter.Tab.main)
            
            TabItems.todayTab()
                .tag(TabRouter.Tab.today)
            
            TabItems.calendarTab()
                .tag(TabRouter.Tab.calendar)
            
            TabItems.settingsTab()
                .tag(TabRouter.Tab.settings)
        }
        .accentColor(.LabelColors.labelSecondary)
        .environmentObject(router)
    }
}

#Preview {
    RootView()
}
