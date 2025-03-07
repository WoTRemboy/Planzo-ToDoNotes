//
//  MainViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow) var addTaskButtonGlow: Bool = false
    @AppStorage(Texts.UserDefaults.taskCreation) private var taskCreationFullScreen: TaskCreation = .popup
    
    @Published private(set) var selectedFilter: Filter = .active
    @Published internal var selectedFolder: Folder = .all
    @Published internal var importance: Bool = false
    
    @Published internal var showingTaskCreateView: Bool = false
    @Published internal var showingTaskCreateViewFullscreen: Bool = false
    @Published internal var showingTaskRemoveAlert: Bool = false
    
    @Published internal var selectedTask: TaskEntity? = nil
    @Published internal var taskManagementHeight: CGFloat = 15
    
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    internal func toggleShowingCreateView() {
        taskCreationFullScreen == .popup ?
            showingTaskCreateView.toggle() :
                showingTaskCreateViewFullscreen.toggle()
    }
    
    internal func toggleShowingTaskEditView() {
        selectedTask = nil
    }
    
    internal func toggleShowingTaskRemoveAlert() {
        showingTaskRemoveAlert.toggle()
    }
    
    internal func setFilter(to new: Filter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFilter = new
        }
    }
    
    internal func compareFilters(with filter: Filter) -> Bool {
        filter == selectedFilter
    }
    
    internal func setFolder(to new: Folder) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFolder = new
        }
    }
    
    internal func compareFolders(with folder: Folder) -> Bool {
        folder == selectedFolder
    }
    
    internal func toggleImportance() {
        withAnimation(.easeInOut(duration: 0.2)) {
            importance.toggle()
        }
    }
}
