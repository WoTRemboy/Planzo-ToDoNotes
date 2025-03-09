//
//  RootView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var router = TabRouter()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.BackColors.backDefault)
        
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    internal var body: some View {
        FullSwipeNavigationStack {
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
        }
        .accentColor(Color.LabelColors.labelPrimary)
        .environmentObject(router)
    }
}

#Preview {
    ContentView()
//        .environmentObject(CoreDataViewModel())
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
            shadowView.backgroundColor = UIColor.white
            
            shadowView.layer.shadowColor = UIColor.ShadowColors.defaultShadow?.cgColor
            shadowView.layer.shadowOffset = CGSize(width: 0, height: -5)
            shadowView.layer.shadowOpacity = 1
            shadowView.layer.shadowRadius = 10
            
            view.addSubview(shadowView)
            view.bringSubviewToFront(tabBar)
        }
    }
}
