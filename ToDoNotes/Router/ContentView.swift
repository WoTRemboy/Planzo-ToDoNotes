//
//  RootView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

/// The main content view of the app, responsible for setting up tab navigation and injecting view models.
struct ContentView: View {
    
    // MARK: - Properties
    
    /// Tab router to manage selected tab state across the app.
    @StateObject private var router = TabRouter()
    
    /// View models for each tab.
    @StateObject private var mainVM = MainViewModel()
    @StateObject private var todayVM = TodayViewModel()
    @StateObject private var calendarVM = CalendarViewModel()
    @StateObject private var settingsVM: SettingsViewModel
    
    // MARK: - Initialization
    
    /// Initializes the view and configures tab bar appearance and initial settings state.
    init() {
        // Retrieves notification permission status from UserDefaults
        let defaults = UserDefaults.standard
        let rawValue = defaults.string(forKey: Texts.UserDefaults.notifications) ?? String()
        let notificationsStatus = NotificationStatus(rawValue: rawValue) ?? .prohibited
        
        // Initializes SettingsViewModel based on permission status
        self._settingsVM = StateObject(wrappedValue: SettingsViewModel(notificationsEnabled: notificationsStatus == .allowed))
        
        // Configures tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.TabBar.background
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // MARK: - Body
    
    /// The main body rendering a tab view with custom view models and tab routing.
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

// MARK: - Preview

#Preview {
    ContentView()
        .environment(\.managedObjectContext, CoreDataProvider.shared.persistentContainer.viewContext)
}

// MARK: - UITabBarController Shadow Extension


/// Adds a custom shadow background behind the tab bar using a shadow layer.
extension UITabBarController {
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == Texts.AccessibilityIdentifier.tabBarShadow }) {
            // Updates the frame if shadow view already exists
            shadowView.frame = tabBar.frame
        } else {
            // Creates a new shadow view
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
