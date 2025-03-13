//
//  RootView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var router = TabRouter()
    
    @StateObject private var mainVM = MainViewModel()
    @StateObject private var todayVM = TodayViewModel()
    @StateObject private var calendarVM = CalendarViewModel()
    @StateObject private var settingsVM: SettingsViewModel
    
    init() {
        let defaults = UserDefaults.standard
        let rawValue = defaults.string(forKey: Texts.UserDefaults.notifications) ?? String()
        let notificationsStatus = NotificationStatus(rawValue: rawValue) ?? .prohibited
        
        self._settingsVM = StateObject(wrappedValue: SettingsViewModel(notificationsEnabled: notificationsStatus == .allowed))
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.TabBar.background
        
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    internal var body: some View {
        FullSwipeNavigationStack {
            TabView(selection: $router.selectedTab) {
                TabItems.mainTab(isSelected: router.selectedTab == .main)
                    .environmentObject(mainVM)
                    .tag(TabRouter.Tab.main)
                
                TabItems.todayTab(isSelected: router.selectedTab == .today)
                    .environmentObject(todayVM)
                    .tag(TabRouter.Tab.today)
                
                TabItems.calendarTab(isSelected: router.selectedTab == .calendar)
                    .environmentObject(calendarVM)
                    .tag(TabRouter.Tab.calendar)
                
                TabItems.settingsTab(isSelected: router.selectedTab == .settings)
                    .environmentObject(settingsVM)
                    .tag(TabRouter.Tab.settings)
            }
        }
        .accentColor(Color.LabelColors.labelPrimary)
        .environmentObject(router)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, CoreDataProvider.shared.persistentContainer.viewContext)
}


extension UITabBarController {
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == Texts.AccessibilityIdentifier.tabBarShadow }) {
            shadowView.frame = tabBar.frame
        } else {
            let shadowView = UIView(frame: .zero)
            shadowView.frame = tabBar.frame
            shadowView.accessibilityIdentifier = Texts.AccessibilityIdentifier.tabBarShadow
            shadowView.backgroundColor = UIColor.backDefault
            
            shadowView.layer.shadowColor = UIColor.ShadowColors.navBar?.cgColor
            shadowView.layer.shadowOffset = CGSize(width: 0, height: -5)
            shadowView.layer.shadowOpacity = 1
            shadowView.layer.shadowRadius = 10
            
            view.addSubview(shadowView)
            view.bringSubviewToFront(tabBar)
        }
    }
}
