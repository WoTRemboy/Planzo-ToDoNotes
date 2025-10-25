//
//  MainViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI
import CoreData

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
    @Published internal var selectedFolder: Folder? = nil {
        didSet { fetchTasks() }
    }
    /// Whether only important tasks are displayed.
    @Published internal var importance: Bool = false
    /// Search text input for filtering tasks.
    @Published internal var searchText: String = String()
    
    /// Flags controlling the visibility of different UI elements.
    @Published internal var showingTaskCreateView: Bool = false
    @Published internal var showingTaskCreateViewFullscreen: Bool = false
    @Published internal var showingTaskRemoveAlert: Bool = false
    @Published internal var showingTaskEditRemovedAlert: Bool = false
    @Published internal var showingFolderSetupView: Bool = false
    @Published internal var showingSearchBar: Bool = false
    @Published internal var showingShareSheet: Bool = false
    @Published internal var showingSubscriptionPage: Bool = false
    
    /// The selected task for editing or viewing.
    @Published internal var selectedTask: TaskEntity? = nil
    @Published internal var selectedTaskFolder: Folder = .mock()
    
    /// The task selected for restoring from deleted.
    @Published internal var removedTask: TaskEntity? = nil
    /// The height of the task management view (dynamic sizing).
    @Published internal var taskManagementHeight: CGFloat = 15
    
    /// List of folders loaded from Core Data.
    @Published internal var folders: [Folder] = []
    
    /// All tasks loaded from Core Data.
    @Published internal var allTasks: [TaskEntity] = []
    
    // MARK: - Computed Properties
    
    /// Formatted string representing today's date.
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    /// Tasks segmented and sorted by date, pin, and deadline.
    internal var segmentedAndSortedTasksArray: [(Date?, [TaskEntity])] {
        let calendar = Calendar.current
        // Optionally filter by folder
        let filteredTasks = allTasks.filter { task in
            !task.removed // Only not deleted
        }
        let grouped = Dictionary(grouping: filteredTasks.lazy) { task -> Date in
            let refDate = task.target ?? task.created ?? Date.distantPast
            return calendar.startOfDay(for: refDate)
        }
        // Group by normalized day (or nil if no target)
        return grouped.map { (key, tasks) in
            let sortedTasks = tasks.sorted { t1, t2 in
                if t1.pinned != t2.pinned {
                    return t1.pinned && !t2.pinned
                }
                
                let d1 = (t1.target != nil && t1.hasTargetTime) ? t1.target! : (Date.distantFuture + t1.created!.timeIntervalSinceNow)
                let d2 = (t2.target != nil && t2.hasTargetTime) ? t2.target! : (Date.distantFuture + t2.created!.timeIntervalSinceNow)
                return d1 < d2
            }
            return (key, sortedTasks)
        }
        .sorted { ($0.0 ?? Date.distantPast) < ($1.0 ?? Date.distantPast) }
    }
    
    /// Tasks filtered by search text, importance, filter, and folder.
    internal var filteredSegmentedTasks: [(Date?, [TaskEntity])] {
        segmentedAndSortedTasksArray.lazy.compactMap { (date, tasks) in
            let filteredTasks = tasks.lazy.filter { task in
                if !self.searchText.isEmpty {
                    let searchTerm = self.searchText
                    let nameMatches = task.name?.localizedCaseInsensitiveContains(searchTerm) ?? false
                    let detailsMatches = task.details?.localizedCaseInsensitiveContains(searchTerm) ?? false
                    if !nameMatches && !detailsMatches {
                        return false
                    }
                }
                if self.importance && !task.important { return false }
                return self.taskMatchesFilter(for: task)
            }
            
            return filteredTasks.isEmpty ? nil : (date, Array(filteredTasks))
        }
        .sorted { ($0.0 ?? Date.distantPast) < ($1.0 ?? Date.distantPast) }
    }
    
    // MARK: - Private Properties
    
    private var coreDataObserver: NSObjectProtocol? = nil
    
    // MARK: - Initializer

    init() {
        self.reloadFolders()
        self.fetchTasks()
        
        if let first = folders.first {
            selectedFolder = first
        } else {
            selectedFolder = nil
        }
        
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        
        coreDataObserver = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: context, queue: .main) { [weak self] _ in
            self?.reloadFolders()
            self?.fetchTasks()
        }
    }
    
    deinit {
        if let observer = coreDataObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Methods
    
    /// Reload folders from Core Data.
    internal func reloadFolders() {
        self.folders = FolderCoreDataService.shared.loadFolders()
    }
    
    /// Fetch tasks from Core Data and assign to allTasks.
    internal func fetchTasks() {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.target, ascending: true)]
        
        if let folder = selectedFolder, folder.system, !folder.shared {
            request.predicate = nil
        } else if let folder = selectedFolder {
            request.predicate = NSPredicate(format: "folder.id == %@", folder.id as CVarArg)
        }
        
        do {
            let tasks = try context.fetch(request)
            DispatchQueue.main.async {
                self.allTasks = tasks
            }
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }
    
    // MARK: - Task Creation Methods
    
    /// Toggles between showing popup or full-screen task creation view.
    internal func toggleShowingCreateView() {
        taskCreationFullScreen == .fullScreen ?
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
    
    internal func toggleShowingShareSheet() {
        showingShareSheet.toggle()
    }
    
    internal func toggleShowingFolderSetupView() {
        showingFolderSetupView.toggle()
    }
    
    internal func toggleShowingSubscriptionPage() {
        showingSubscriptionPage.toggle()
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
    
    internal func setTaskFolder(to folderEntity: FolderEntity?) {
        guard let folderEntity else { return }
        let folder = Folder(from: folderEntity)
        selectedTaskFolder = folder
    }
    
    /// Toggles the importance-only filter.
    internal func toggleImportance() {
        withAnimation(.easeInOut(duration: 0.2)) {
            importance.toggle()
        }
    }
    
    // MARK: - Task Filtering Methods
    
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
            if let target = task.target, task.hasTargetTime,
               let oneDay = Calendar.current.date(byAdding: .day, value: -1, to: .now),
               target < oneDay {
                return false
            }
//            if let target = task.target, !task.hasTargetTime, target < Calendar.current.startOfDay(for: .now) {
//                return false
//            }
            
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
            
            if let target = task.target, task.hasTargetTime,
               let oneDay = Calendar.current.date(byAdding: .day, value: -1, to: .now),
               target < oneDay {
                return task.completed == 0
            }
//            if let target = task.target, !task.hasTargetTime, target < Calendar.current.startOfDay(for: .now) {
//                return true
//            }
            
            if let count = task.notifications?.count, count > 0,
               let target = task.target, target < .now { return true }
            
            return false
            
        case .unsorted:
            return true
        case .deleted:
            return false
        }
    }
}
