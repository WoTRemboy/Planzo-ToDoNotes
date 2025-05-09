//
//  MainViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

/// ViewModel responsible for managing the main screen's filters, folders, search, and task creation behavior.
final class MainViewModel: ObservableObject {
    
    // MARK: - UserDefaults Stored Properties
    
    /// Controls whether the Add Task button has a glow effect.
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow)
    internal var addTaskButtonGlow: Bool = false
    
    /// Defines the preferred task creation style (popup or full screen).
    @AppStorage(Texts.UserDefaults.taskCreation)
    private var taskCreationFullScreen: TaskCreation = .popup
    
    // MARK: - Published State Properties
    
    /// Currently selected task filter (e.g., Active, Completed).
    @Published private(set) var selectedFilter: Filter = .active
    /// Currently selected folder (e.g., Reminders, Tasks, Lists).
    @Published internal var selectedFolder: Folder = .all
    /// Whether only important tasks are displayed.
    @Published internal var importance: Bool = false
    /// Search text input for filtering tasks.
    @Published internal var searchText: String = String()
    
    /// Flags controlling the visibility of different UI elements.
    @Published internal var showingTaskCreateView: Bool = false
    @Published internal var showingTaskCreateViewFullscreen: Bool = false
    @Published internal var showingTaskRemoveAlert: Bool = false
    @Published internal var showingTaskEditRemovedAlert: Bool = false
    @Published internal var showingSearchBar: Bool = false
    
    /// The selected task for editing or viewing.
    @Published internal var selectedTask: TaskEntity? = nil
    /// The task selected for restoring from deleted.
    @Published internal var removedTask: TaskEntity? = nil
    /// The height of the task management view (dynamic sizing).
    @Published internal var taskManagementHeight: CGFloat = 15
    
    // MARK: - Computed Properties
    
    /// Formatted string representing today's date.
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    // MARK: - Task Creation Methods
    
    /// Toggles between showing popup or full-screen task creation view.
    internal func toggleShowingCreateView() {
        taskCreationFullScreen == .fullScreen || selectedFolder == .lists ?
        showingTaskCreateViewFullscreen.toggle() :
        showingTaskCreateView.toggle()
    }
    
    /// Hides the task edit view.
    internal func toggleShowingTaskEditView() {
        selectedTask = nil
    }
    
    // MARK: - Alert and Search Bar Control Methods
    
    /// Toggles the task removal confirmation alert.
    internal func toggleShowingTaskRemoveAlert() {
        showingTaskRemoveAlert.toggle()
    }
    
    /// Toggles the edit alert for restoring deleted tasks.
    internal func toggleShowingEditRemovedAlert() {
        showingTaskEditRemovedAlert.toggle()
    }
    
    /// Toggles the visibility of the search bar.
    internal func toggleShowingSearchBar() {
        showingSearchBar.toggle()
    }
    
    // MARK: - Filter and Folder Management
    
    /// Changes the currently active filter with animation.
    /// - Parameter new: The new filter to apply.
    internal func setFilter(to new: Filter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFilter = new
        }
    }
    
    /// Compares a given filter to the currently selected one.
    /// - Returns: `true` if it matches, otherwise `false`.
    internal func compareFilters(with filter: Filter) -> Bool {
        filter == selectedFilter
    }
    
    /// Changes the currently active folder with animation.
    /// - Parameter new: The new folder to apply.
    internal func setFolder(to new: Folder) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFolder = new
        }
    }
    
    /// Compares a given folder to the currently selected one.
    /// - Returns: `true` if it matches, otherwise `false`.
    internal func compareFolders(with folder: Folder) -> Bool {
        folder == selectedFolder
    }
    
    /// Toggles the importance-only filter.
    internal func toggleImportance() {
        withAnimation(.easeInOut(duration: 0.2)) {
            importance.toggle()
        }
    }
    
    // MARK: - Task Filtering Methods
    
    /// Checks if a task belongs to the currently selected folder.
    /// - Parameter task: The task entity to check.
    /// - Returns: `true` if the task matches the current folder filter.
    internal func taskMatchesFolder(for task: TaskEntity) -> Bool {
        switch selectedFolder {
        case .all:
            return true
        case .reminders:
            return task.folder == Folder.reminders.rawValue
        case .tasks:
            return task.folder == Folder.tasks.rawValue
        case .lists:
            return task.folder == Folder.lists.rawValue
        case .other:
            return task.folder == Folder.other.rawValue
        }
    }
    
    /// Checks if a task matches the currently selected task filter (e.g., active, completed).
    /// - Parameter task: The task entity to evaluate.
    /// - Returns: `true` if the task fits the filter criteria.
    internal func taskMatchesFilter(for task: TaskEntity) -> Bool {
        // Deleted tasks are only shown in the "Deleted" filter
        if task.removed {
            return selectedFilter == .deleted
        }
        
        switch selectedFilter {
        case .active:
            guard task.completed != 2 else { return false }
            if let target = task.target, task.hasTargetTime, target < .now {
                return false
            }
            if let count = task.notifications?.count, count > 0,
               let target = task.target, target < .now { return false }
            return true
            
        case .outdated:
            if task.completed == 1,
               let target = task.target, task.hasTargetTime, target < .now { return true }
            return false
            
        case .completed:
            return task.completed == 2
            
        case .archived:
            guard task.completed != 2 else { return false }
            
            if let target = task.target, task.hasTargetTime, target < .now {
                return task.completed == 0
            }
            if let count = task.notifications?.count, count > 0,
               let target = task.target, target < .now { return true }
            return false
            
        case .unsorted:
            return true
        case .deleted:
            // Already handled above
            return false
        }
    }
}
