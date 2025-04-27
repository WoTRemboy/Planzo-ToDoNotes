//
//  TabRouter.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

/// A router class that manages the currently selected tab in the tab bar.
final class TabRouter: ObservableObject {
    
    /// The currently selected tab. Defaults to `.main`.
    @Published var selectedTab: Tab = .main
    
    /// The available tabs in the app.
    enum Tab {
        case main
        case today
        case calendar
        case settings
    }
}
