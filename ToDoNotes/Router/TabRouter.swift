//
//  TabRouter.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

final class TabRouter: ObservableObject {
    @Published var selectedTab: Tab = .main
    
    enum Tab {
        case main
        case today
        case calendar
        case settings
    }
}
