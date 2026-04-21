//
//  MainViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI
import CoreData
import OSLog
import UIKit

private let logger = Logger(subsystem: "com.todonotes.main", category: "MainViewModel")

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
    @Published private(set) var selectedFilter: Filter = .active {
        didSet { updateTaskFetch(for: selectedFolder) }
    }
    /// Currently selected folder (e.g., Reminders, Tasks, Lists).
    @Published internal var selectedFolder: Folder? = nil {
        didSet { updateTaskFetch(for: selectedFolder) }
    }
    /// Whether only important tasks are displayed.
    @Published internal var importance: Bool = false {
        didSet { updateTaskFetch(for: selectedFolder) }
    }
    /// Search text input for filtering tasks.
    @Published internal var searchText: String = String() {
        didSet { updateTaskFetch(for: selectedFolder) }
    }
    
    /// Flags controlling the visibility of different UI elements.
    @Published internal var showingTaskCreateView: Bool = false
    @Published internal var showingTaskCreateViewFullscreen: Bool = false
    @Published internal var showingTaskRemoveAlert: Bool = false
    @Published internal var showingSyncErrorAlert: Bool = false
    @Published internal var showingTaskEditRemovedAlert: Bool = false
    @Published internal var showingFolderSetupView: Bool = false
    @Published internal var showingSearchBar: Bool = false
    @Published internal var showingShareSheet: Bool = false
    @Published internal var showingSubscriptionPage: Bool = false
    
    /// Confirm alert for deleting shared (non-owner) task
    @Published internal var showingConfirmSharedDelete: Bool = false
    /// Target task for shared delete confirmation
    @Published internal var sharedDeleteTargetTask: TaskEntity? = nil
    /// Processing flag to prevent re-entrancy while delete flow is in progress
    @Published internal var isProcessingSharedDelete: Bool = false
    
    /// The selected task for editing or viewing.
    @Published internal var selectedTask: TaskEntity? = nil
    @Published internal var sharingTask: TaskEntity? = nil
    @Published internal var selectedTaskFolder: Folder = .mock()
    
    /// The task selected for restoring from deleted.
    @Published internal var removedTask: TaskEntity? = nil
    /// The height of the task management view (dynamic sizing).
    @Published internal var taskManagementHeight: CGFloat = 15
    
    /// List of folders loaded from Core Data.
    @Published internal var folders: [Folder] = []
    
    /// All tasks loaded from Core Data.
    @Published internal var allTasks: [TaskEntity] = [] {
        didSet { rebuildDerivedTasks() }
    }

    @Published private(set) var segmentedAndSortedTasksArray: [(Date?, [TaskEntity])] = []
    @Published private(set) var filteredSegmentedTasks: [(Date?, [TaskEntity])] = []
    
    // MARK: - Computed Properties
    
    /// Formatted string representing today's date.
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    
    // MARK: - Private Properties
    
    private let taskFetchController: TaskFetchController
    private let folderFetchController: FolderFetchController
    
    // MARK: - Initializer

    init() {
        taskFetchController = TaskFetchController()
        folderFetchController = FolderFetchController()

        taskFetchController.onUpdate = { [weak self] tasks in
            self?.allTasks = tasks
        }

        folderFetchController.onUpdate = { [weak self] folders in
            guard let self = self else { return }
            self.folders = self.filteredFolders(folders)
            self.ensureSelectedFolder()
        }

        folderFetchController.start()
        updateTaskFetch(for: selectedFolder)
    }
    
    // MARK: - Methods
    
    /// Ensures a valid selected folder after folder updates.
    private func ensureSelectedFolder() {
        if let selected = selectedFolder, folders.contains(where: { $0 == selected }) {
            return
        }
        selectedFolder = folders.first
    }

    private func filteredFolders(_ folders: [Folder]) -> [Folder] {
        let hasSharedTasks = fetchHasSharedTasks()
        return folders.filter { folder in
            guard folder.system, folder.shared else { return true }
            return hasSharedTasks
        }
    }

    private func fetchHasSharedTasks() -> Bool {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "members > 0")
        request.fetchLimit = 1
        if let count = try? context.count(for: request) {
            return count > 0
        }
        return false
    }

    /// Updates the task fetch controller when folder selection changes.
    private func updateTaskFetch(for folder: Folder?) {
        guard let folder else {
            allTasks = []
            return
        }

        let predicate = buildTaskPredicate(for: folder)
        taskFetchController.update(predicate: predicate)
    }

    private func buildTaskPredicate(for folder: Folder) -> NSPredicate? {
        var subpredicates = [NSPredicate]()

        if folder.system, folder.shared {
            subpredicates.append(NSPredicate(format: "members > 0"))
        } else if !folder.system {
            subpredicates.append(NSPredicate(format: "folder.id == %@", folder.id as CVarArg))
        }

        if !searchText.isEmpty {
            let searchPredicate = NSPredicate(
                format: "(name CONTAINS[cd] %@) OR (details CONTAINS[cd] %@)",
                searchText,
                searchText
            )
            subpredicates.append(searchPredicate)
        }

        if importance {
            subpredicates.append(NSPredicate(format: "important == YES"))
        }

        subpredicates.append(filterPredicate(for: selectedFilter))

        if subpredicates.isEmpty {
            return nil
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }

    private func filterPredicate(for filter: Filter) -> NSPredicate {
        let now = Date()
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now

        switch filter {
        case .deleted:
            return NSPredicate(format: "removed == YES")
        case .completed:
            return NSPredicate(format: "removed == NO AND completed == 2")
        case .outdated:
            return NSPredicate(format: "removed == NO AND completed == 1 AND hasTargetTime == YES AND target < %@", now as NSDate)
        case .archived:
            return NSPredicate(
                format: "removed == NO AND completed != 2 AND ((hasTargetTime == YES AND target < %@ AND completed == 0) OR (notifications.@count > 0 AND target < %@))",
                oneDayAgo as NSDate,
                oneDayAgo as NSDate
            )
        case .active:
            return NSPredicate(
                format: "removed == NO AND completed != 2 AND ((hasTargetTime == NO) OR (target == nil) OR (target >= %@)) AND ((notifications.@count == 0) OR (target == nil) OR (target >= %@))",
                oneDayAgo as NSDate,
                oneDayAgo as NSDate
            )
        case .unsorted:
            return NSPredicate(format: "removed == NO")
        }
    }

    private func rebuildDerivedTasks() {
        guard !allTasks.isEmpty else {
            withAnimation(.easeInOut(duration: 0.1)) {
                segmentedAndSortedTasksArray = []
                filteredSegmentedTasks = []
            }
            return
        }

        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allTasks) { task -> Date in
            let refDate = task.target ?? task.created ?? Date.distantPast
            return calendar.startOfDay(for: refDate)
        }

        let segmented = grouped.map { (key, tasks) in
            let sortedTasks = tasks.sorted { t1, t2 in
                if t1.pinned != t2.pinned {
                    return t1.pinned && !t2.pinned
                }

                let firstDate = t1.created ?? .now
                let d1: Date
                if let target = t1.target, t1.hasTargetTime {
                    d1 = target
                } else {
                    d1 = Date.distantFuture + firstDate.timeIntervalSinceNow
                }

                let secondDate = t2.created ?? .now
                let d2: Date
                if let target = t2.target, t2.hasTargetTime {
                    d2 = target
                } else {
                    d2 = Date.distantFuture + secondDate.timeIntervalSinceNow
                }

                return d1 < d2
            }
            return (key, sortedTasks)
        }
        .sorted { $0.0 < $1.0 }

        withAnimation(.easeInOut(duration: 0.1)) {
            segmentedAndSortedTasksArray = segmented
            filteredSegmentedTasks = segmented
        }
    }
    
    // MARK: - Task Creation Methods
    
    /// Toggles between showing popup or full-screen task creation view.
    internal func toggleShowingCreateView() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            showingTaskCreateViewFullscreen.toggle()
            return
        }

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
    
    internal func toggleShowingSyncErrorAlert() {
        showingSyncErrorAlert.toggle()
    }
    
    /// Toggles the edit alert for restoring deleted tasks.
    internal func toggleShowingEditRemovedAlert() {
        showingTaskEditRemovedAlert.toggle()
    }
    
    /// Toggles the visibility of the search bar.
    internal func toggleShowingSearchBar() {
        showingSearchBar.toggle()
    }

    internal func setShowingSearchBar(to isPresented: Bool) {
        showingSearchBar = isPresented
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
    
    internal func setSharingTask(to task: TaskEntity?) {
        sharingTask = task
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
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        withAnimation(.easeInOut(duration: 0.2)) {
            importance.toggle()
        }
        haptic.impactOccurred()
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
            
            if let count = task.notifications?.count, count > 0,
               let target = task.target,
               let oneDay = Calendar.current.date(byAdding: .day, value: -1, to: .now),
               target < oneDay
            { return false }
            
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
            
            if let count = task.notifications?.count, count > 0,
               let target = task.target,
               let oneDay = Calendar.current.date(byAdding: .day, value: -1, to: .now),
               target < oneDay
            { return true }
            
            return false
            
        case .unsorted:
            return true
        case .deleted:
            return false
        }
    }
    
    internal func handleSync(authService: AuthNetworkService) {
        if authService.isAuthorized, let user = authService.currentUser {
            FullSyncNetworkService.shared.syncDeltaData(since: user.lastSyncAt) { result in
                switch result {
                case .success(_):
                    logger.info("Delta data sync successful since: \(user.lastSyncAt ?? "nil")")
                case .failure(let error):
                    logger.error("Delta data sync failed with error: \(error)")
                }
            }
            logger.info("SyncAllBackTasks started for syncing all tasks.")
        } else {
            logger.error("SyncAllBackTasks not starting as user not authorized or syncStatus is not .updated")
        }
    }
    
    // MARK: - Shared delete confirmation (non-owner)

    internal func requestConfirmSharedDelete(for task: TaskEntity) {
        guard !self.showingConfirmSharedDelete, !self.isProcessingSharedDelete else { return }
        self.sharedDeleteTargetTask = task
        self.showingConfirmSharedDelete = true
    }
    
    internal func cancelConfirmSharedDelete() {
        self.showingConfirmSharedDelete = false
        self.sharedDeleteTargetTask = nil
    }
    
    internal func performConfirmSharedDelete() {
        guard !self.isProcessingSharedDelete else { return }
        self.isProcessingSharedDelete = true
        
        guard let task = self.sharedDeleteTargetTask else {
            self.isProcessingSharedDelete = false
            cancelConfirmSharedDelete()
            return
        }
        guard let listId = task.serverId, !listId.isEmpty else {
            Toast.shared.present(title: Texts.Settings.Sync.Retry.title)
            logger.error("No serverId when trying to remove my membership from shared list task.")
            self.isProcessingSharedDelete = false
            cancelConfirmSharedDelete()
            return
        }
        ShareAccessService.shared.deleteMyMembership(listId: listId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    withAnimation(.easeInOut(duration: 0.2)) {
                        do {
                            UNUserNotificationCenter.current().removeNotifications(for: task.notifications)
                            try TaskService.deleteRemovedTask(for: task)
                            logger.debug("Successfully removed membership and deleted local task: \(task.name ?? "unknown") \(task.id?.uuidString ?? "unknown")")
                        } catch {
                            logger.error("Failed to delete local task after membership removal: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    Toast.shared.present(title: Texts.Settings.Sync.Retry.title)
                    logger.error("Failed to remove membership from list before local delete: \(error.localizedDescription)")
                }
                self.isProcessingSharedDelete = false
                self.cancelConfirmSharedDelete()
            }
        }
    }
}

