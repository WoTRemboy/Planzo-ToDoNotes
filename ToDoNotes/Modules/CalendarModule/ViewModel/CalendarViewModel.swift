//
//  CalendarViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI
import UserNotifications
import OSLog

private let logger = Logger(subsystem: "com.todonotes.calendar", category: "CalendarViewModel")

/// ViewModel managing the state and user interactions for the Calendar screen.
final class CalendarViewModel: ObservableObject {
    
    // MARK: - Stored Properties
    
    /// Indicates whether the glowing effect is enabled for the add task button.
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow)
    internal var addTaskButtonGlow: Bool = false
    
    /// Defines the presentation style for creating a new task (popup or full screen).
    @AppStorage(Texts.UserDefaults.taskCreation)
    private var taskCreationFullScreen: TaskCreation = .popup
    
    // MARK: - Published Properties (View State)
    
    /// Whether the task creation view (as sheet) is currently shown.
    @Published internal var showingTaskCreateView: Bool = false
    /// Whether the task creation view (as full screen) is currently shown.
    @Published internal var showingTaskCreateViewFullscreen: Bool = false
    /// Whether the month selector (calendar picker) is currently shown.
    @Published internal var showingCalendarSelector: Bool = false
    @Published internal var showingFolderSetupView: Bool = false
    @Published internal var showingShareSheet: Bool = false
    
    /// The task currently selected for editing.
    @Published internal var selectedTask: TaskEntity? = nil
    @Published internal var sharingTask: TaskEntity? = nil
    @Published internal var selectedTaskFolder: Folder = .mock()
    /// The date currently selected in the calendar (defaults to today).
    @Published internal var selectedDate: Date = .now.startOfDay
    
    /// Height of the task creation or editing panel.
    @Published internal var taskManagementHeight: CGFloat = 15
    
    /// The current month/year displayed in the calendar.
    @Published internal var calendarDate: Date = Date.now {
        didSet {
            updateDays()
            selectDay()
        }
    }
    
    /// Days to display in the custom calendar grid.
    @Published internal var days: [Date] = []
    /// Names of the weekdays with capitalized first letters, localized.
    @Published internal var daysOfWeek: [String] = Date.capitalizedFirstLettersOfWeekdays
    
    @Published internal var folders: [Folder] = []
    private var coreDataObserver: NSObjectProtocol? = nil
    
    // MARK: - Shared delete confirmation
    
    /// Confirm alert for deleting shared (non-owner) task
    @Published internal var showingConfirmSharedDelete: Bool = false
    /// Target task for shared delete confirmation
    @Published internal var sharedDeleteTargetTask: TaskEntity? = nil
    /// Processing flag to prevent re-entrancy while delete flow is in progress
    @Published internal var isProcessingSharedDelete: Bool = false
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel and sets up the initial days array.
    init() {
        updateDays()
        daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            let newDaysOfWeek = Date.capitalizedFirstLettersOfWeekdays
            if self.daysOfWeek != newDaysOfWeek {
                self.daysOfWeek = newDaysOfWeek
                self.updateDays()
            }
        }
        
        self.reloadFolders()
        
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        coreDataObserver = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: context, queue: .main) { [weak self] _ in
            self?.reloadFolders()
        }
    }
    
    // MARK: - Task Create View Handling
    
    /// Toggles the display of the task creation view based on user settings (popup or full screen).
    internal func toggleShowingTaskCreateView() {
        taskCreationFullScreen == .popup
        ? showingTaskCreateView.toggle()
        : showingTaskCreateViewFullscreen.toggle()
    }
    
    /// Dismisses the task editing view.
    internal func toggleShowingTaskEditView() {
        selectedTask = nil
    }
    
    internal func toggleShowingFolderSetupView() {
        showingFolderSetupView.toggle()
    }
    
    // MARK: - Calendar Handling
    
    /// Toggles the visibility of the calendar month/year selector.
    internal func toggleShowingCalendarSelector() {
        showingCalendarSelector.toggle()
    }
    
    /// Updates the array of days to display when the calendar month/year changes.
    private func updateDays() {
        days = calendarDate.calendarDisplayDays
    }
    
    /// Updates the selected date to the start of the month (or selected day).
    private func selectDay() {
        selectedDate = Calendar.current.startOfDay(for: calendarDate)
    }
    
    /// Restores today's date as the selected and displayed date, unless already showing today.
    internal func restoreTodayDate() {
        guard selectedDate != .now.startOfDay else { return }
        calendarDate = .now.startOfDay
    }
    
    internal func toggleShowingShareSheet() {
        showingShareSheet.toggle()
    }
    
    internal func setTaskFolder(to folderEntity: FolderEntity?) {
        guard let folderEntity else { return }
        let folder = Folder(from: folderEntity)
        selectedTaskFolder = folder
    }
    
    internal func setSharingTask(to task: TaskEntity?) {
        self.sharingTask = task
    }
    
    internal func reloadFolders() {
        self.folders = FolderCoreDataService.shared.loadFolders().sorted { $0.order < $1.order }
    }
    
    // MARK: - Shared delete confirmation
    
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
                            logger.debug("Successfully removed membership and deleted local task.")
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
