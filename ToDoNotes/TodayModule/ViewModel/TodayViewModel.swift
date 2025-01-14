//
//  TodayViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

final class TodayViewModel: ObservableObject {
    
    @Published internal var showingTaskEditView: Bool = false
    @Published internal var taskManagementHeight: CGFloat = 15
    
    private(set) var todayDate: Date = Date.now
    
    internal func toggleShowingTaskEditView() {
        showingTaskEditView.toggle()
    }
}
