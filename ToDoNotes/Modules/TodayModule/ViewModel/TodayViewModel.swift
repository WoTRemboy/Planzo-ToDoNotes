//
//  TodayViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

final class TodayViewModel: ObservableObject {
    
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow) var addTaskButtonGlow: Bool = false
    @AppStorage(Texts.UserDefaults.taskCreation) private var taskCreationFullScreen: TaskCreation = .popup
    
    @Published internal var selectedTask: TaskEntity? = nil
    @Published internal var searchText: String = String()
    @Published internal var taskManagementHeight: CGFloat = 15
    
    @Published internal var showingTaskCreateView: Bool = false
    @Published internal var showingTaskCreateViewFullscreen: Bool = false
    @Published internal var showingSearchBar: Bool = false
    
    @Published internal var importance: Bool = false
    
    private(set) var todayDate: Date = Date.now
    
    internal func toggleShowingTaskCreateView() {
        taskCreationFullScreen == .popup ?
            showingTaskCreateView.toggle() :
                showingTaskCreateViewFullscreen.toggle()
    }
    
    internal func toggleShowingTaskEditView() {
        selectedTask = nil
    }
    
    internal func toggleShowingSearchBar() {
        showingSearchBar.toggle()
    }
    
    internal func toggleImportance() {
        withAnimation(.easeInOut(duration: 0.2)) {
            importance.toggle()
        }
    }
}
