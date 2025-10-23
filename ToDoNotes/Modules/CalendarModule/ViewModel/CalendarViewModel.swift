//
//  CalendarViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

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
    @Published internal var selectedTaskFolder: Folder = .mock
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
    
    internal func reloadFolders() {
        self.folders = FolderCoreDataService.shared.loadFolders().sorted { $0.order < $1.order }
    }
}
