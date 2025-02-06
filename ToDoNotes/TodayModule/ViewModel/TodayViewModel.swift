//
//  TodayViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

final class TodayViewModel: ObservableObject {
    
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow) var addTaskButtonGlow: Bool = false
    
    @Published internal var showingTaskCreateView: Bool = false
    @Published internal var selectedTask: TaskEntity? = nil
    @Published internal var taskManagementHeight: CGFloat = 15
    
    private(set) var todayDate: Date = Date.now
    
    internal func toggleShowingTaskCreateView() {
        showingTaskCreateView.toggle()
    }
    
    internal func toggleShowingTaskEditView() {
        selectedTask = nil
    }
}
