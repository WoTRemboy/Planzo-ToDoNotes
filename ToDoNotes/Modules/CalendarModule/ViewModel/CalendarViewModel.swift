//
//  CalendarViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI
import UserNotifications
import OSLog
import UIKit

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

    /// Stores the calendar display mode between launches (month/week).
    @AppStorage(Texts.UserDefaults.calendarDisplayMode)
    private var storedDisplayMode: String = CalendarDisplayMode.month.rawValue
    
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
    @Published internal var selectedDate: Date = .now.startOfDay {
        didSet {
            if displayMode == .week {
                updateDays()
                let newDate = selectedDate.startOfDay
                if calendarDate != newDate {
                    calendarDate = newDate
                }
            }
            rebuildDayTasks()
        }
    }

    /// The current display mode for the calendar.
    @Published internal var displayMode: CalendarDisplayMode = .month {
        didSet {
            storedDisplayMode = displayMode.rawValue
            calendarDate = selectedDate.startOfDay
        }
    }
    
    /// Height of the task creation or editing panel.
    @Published internal var taskManagementHeight: CGFloat = 15
    
    /// The current month/year displayed in the calendar.
    @Published internal var calendarDate: Date = Date.now {
        didSet {
            updateDays()
            switch displayMode {
            case .month:
                selectDay()
            case .week:
                let newDate = Calendar.current.startOfDay(for: calendarDate)
                if selectedDate != newDate {
                    selectedDate = newDate
                }
            }
        }
    }

    /// Days to display in the custom calendar grid.
    @Published internal var days: [Date] = []
    /// Names of the weekdays with capitalized first letters, localized.
    @Published internal var daysOfWeek: [String] = Date.capitalizedFirstLettersOfWeekdays
    
    @Published internal var folders: [Folder] = []
    @Published private(set) var tasks: [TaskEntity] = []
    @Published private(set) var dayTasks: [TaskSection: [TaskEntity]] = [:]
    @Published private(set) var datesWithTasks: [Date: Int] = [:]

    private let taskFetchController: TaskFetchController
    private let folderFetchController: FolderFetchController
    private var currentFetchInterval: DateInterval? = nil
    
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
        taskFetchController = TaskFetchController()
        folderFetchController = FolderFetchController()

        taskFetchController.onUpdate = { [weak self] tasks in
            self?.tasks = tasks
            self?.rebuildDerivedData()
        }

        folderFetchController.onUpdate = { [weak self] folders in
            self?.folders = folders.sorted { $0.order < $1.order }
        }

        displayMode = CalendarDisplayMode(rawValue: storedDisplayMode) ?? .month
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

        folderFetchController.start()
    }
    
    // MARK: - Task Create View Handling
    
    /// Toggles the display of the task creation view based on user settings (popup or full screen).
    internal func toggleShowingTaskCreateView() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            showingTaskCreateViewFullscreen.toggle()
            return
        }

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
        switch displayMode {
        case .month:
            days = calendarDate.calendarDisplayDays
        case .week:
            days = selectedDate.weekDisplayDays
        }
        updateTaskFetchRange()
    }
    
    /// Updates the selected date to the start of the month (or selected day).
    private func selectDay() {
        selectedDate = Calendar.current.startOfDay(for: calendarDate)
    }
    
    /// Restores today's date as the selected and displayed date, unless already showing today.
    internal func restoreTodayDate() {
        guard selectedDate != .now.startOfDay else { return }
        if displayMode == .week {
            selectedDate = .now.startOfDay
        } else {
            calendarDate = .now.startOfDay
        }
    }

    /// Move the calendar month forward or backward.
    internal func calendarMonthMove(for direction: CalendarMovement) {
        let value: Int
        switch direction {
        case .forward:
            value = 1
        case .backward:
            value = -1
        }
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: calendarDate) {
            calendarDate = newDate
        }
    }

    /// Move the calendar week forward or backward.
    internal func calendarWeekMove(for direction: CalendarMovement) {
        let value: Int
        switch direction {
        case .forward:
            value = 7
        case .backward:
            value = -7
        }
        if let newDate = Calendar.current.date(byAdding: .day, value: value, to: selectedDate) {
            selectedDate = newDate.startOfDay
        }
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
    
    private static let rangeSortDescriptors: [NSSortDescriptor] = [
        NSSortDescriptor(key: "target", ascending: true),
        NSSortDescriptor(key: "created", ascending: true)
    ]

    private static func rangePredicate(from start: Date, to end: Date) -> NSPredicate {
        NSPredicate(
            format: "removed == NO AND ((target >= %@ AND target < %@) OR (target == nil AND created >= %@ AND created < %@))",
            start as NSDate,
            end as NSDate,
            start as NSDate,
            end as NSDate
        )
    }

    private func updateTaskFetchRange() {
        guard let minDay = days.min(), let maxDay = days.max() else {
            currentFetchInterval = nil
            tasks = []
            dayTasks = [:]
            datesWithTasks = [:]
            return
        }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: minDay)
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: maxDay)) ?? maxDay
        let interval = DateInterval(start: start, end: end)

        if currentFetchInterval == interval {
            return
        }

        currentFetchInterval = interval
        let predicate = CalendarViewModel.rangePredicate(from: start, to: end)
        taskFetchController.update(predicate: predicate, sortDescriptors: CalendarViewModel.rangeSortDescriptors)
    }

    private func rebuildDerivedData() {
        var counts: [Date: Int] = [:]
        let calendar = Calendar.current

        for task in tasks {
            let referenceDate = task.target ?? task.created ?? Date.distantPast
            let day = calendar.startOfDay(for: referenceDate)
            counts[day, default: 0] += 1
        }

        datesWithTasks = counts
        rebuildDayTasks()
    }

    private func rebuildDayTasks() {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: selectedDate)

        let filteredTasks = tasks.lazy.filter { task in
            let taskDate = calendar.startOfDay(for: task.target ?? task.created ?? Date.distantPast)
            return taskDate == day
        }

        let sortedTasks = filteredTasks.sorted { t1, t2 in
            if t1.pinned != t2.pinned {
                return t1.pinned && !t2.pinned
            }

            let firstDate = t1.created ?? .now
            let d1 = (t1.target != nil && t1.hasTargetTime) ? t1.target ?? .now : (Date.distantFuture + firstDate.timeIntervalSinceNow)
            let secondDate = t2.created ?? .now
            let d2 = (t2.target != nil && t2.hasTargetTime) ? t2.target ?? .now : (Date.distantFuture + secondDate.timeIntervalSinceNow)
            return d1 < d2
        }

        var result: [TaskSection: [TaskEntity]] = [:]
        let pinned = sortedTasks.filter { $0.pinned }
        let active = sortedTasks.filter { !$0.pinned && $0.completed != 2 }
        let completed = sortedTasks.filter { !$0.pinned && $0.completed == 2 }

        if !pinned.isEmpty { result[.pinned] = pinned }
        if !active.isEmpty { result[.active] = active }
        if !completed.isEmpty { result[.completed] = completed }

        dayTasks = result
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
