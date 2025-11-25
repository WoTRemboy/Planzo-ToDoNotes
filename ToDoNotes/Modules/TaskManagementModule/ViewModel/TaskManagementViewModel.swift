//
//  TaskManagementViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI
import CoreData
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.todonotes.task_management", category: "TaskManagementViewModel")

final class TaskManagementViewModel: ObservableObject {
    
    // MARK: - Properties
    
    /// Internal reference to checklist entities (for persistence).
    internal var checklistItems: [ChecklistEntity] = []
    
    /// The current notifications permission status.
    internal private(set) var notificationsStatus: NotificationStatus = .prohibited
    
    /// Whether the add task button should glow (persisted).
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow) private var addTaskButtonGlow: Bool = false
    /// Whether task creation is full screen or popup (persisted).
    @AppStorage(Texts.UserDefaults.taskCreation) internal var taskCreationFullScreen: TaskCreation = .popup
    
    /// The current task name text.
    @Published internal var nameText: String
    /// The current task description text.
    @Published internal var descriptionText: String
    /// The current task completion check state.
    @Published internal var check: TaskCheck
    /// The local, editable checklist items for the task.
    @Published internal var checklistLocal: [ChecklistItem] = []
    /// The currently dragged checklist item (for drag-and-drop).
    @Published internal var draggingItem: ChecklistItem? = nil
    /// The text for a new checklist item.
    @Published internal var checkListItemText: String = String()
    
    /// Whether the task is marked as important.
    @Published internal var importance: Bool = false
    /// Whether the task is pinned.
    @Published internal var pinned: Bool = false
    /// Whether the task is marked as removed (for undo/animation).
    @Published internal var removed: Bool = false
    
    /// Whether the share sheet is showing.
    @Published internal var showingShareSheet: Bool = false
    /// The height of the share sheet.
    @Published internal var shareSheetHeight: CGFloat = 0
    
    /// The main target date for the task.
    @Published internal var targetDate: Date
    /// Whether a date is set for the task.
    @Published internal var hasDate: Bool = false
    /// Whether a time is set for the task.
    @Published internal var hasTime: Bool = false
    /// The selected day for the task.
    @Published internal var selectedDay: Date = .now.startOfDay
    /// The selected time for the task.
    @Published internal var selectedTime: Date = .now
    
    /// The selected time type (none or value) for the picker.
    @Published internal var selectedTimeType: TaskTime = .none
    /// The available notification types for the current date/time.
    @Published internal var availableNotifications = [TaskNotification]()
    /// The locally selected notifications for the task.
    @Published internal var notificationsLocal: Set<NotificationItem> = []
    
    /// The selected repeating rule for the task.
    @Published internal var selectedRepeating: TaskRepeating = .none
    
    /// Whether notifications are enabled for the task.
    @Published internal var notificationsCheck: Bool = false
    /// Whether the date picker is showing.
    @Published internal var showingDatePicker: Bool = false
    /// Whether the notification alert is showing.
    @Published internal var showingNotificationAlert: Bool = false
    @Published internal var showingNetworkErrorAlert: Bool = false
    @Published internal var showingDeniedAlert: Bool = false
    @Published internal var showingStopSharingAlert: Bool = false
    @Published internal var showingRemoveMemberAlert: Bool = false
    
    /// The selected share access type for the task.
    @Published internal var shareAccess: ShareAccess = .viewOnly
    @Published internal var shareMembers: [SharingMember] = []
    @Published internal var deniedMembers: [SharingMember] = []
    @Published internal var selectedMember: SharingMember? = nil
    @Published internal var currentRole: ShareAccess = .viewOnly
    @Published internal var sharingTask: TaskEntity? = nil
    
    @Published var isUpdatingMemberRole: Bool = false
    @Published var selectedShareType: ShareAccess = .viewOnly
    
    /// Reference to the TaskEntity being edited (if any).
    private var entity: TaskEntity? = nil
    
    /// The date currently displayed in the calendar view.
    @Published internal var calendarDate: Date = Date.now {
        didSet {
            updateDays()
        }
    }
    
    /// The days of the week, capitalized.
    internal let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    /// The last direction the calendar swapped.
    internal private(set) var calendarSwapDirection: CalendarMovement = .forward
    /// Today's date at start of day.
    internal private(set) var todayDate: Date = Date.now.startOfDay
    /// The days visible in the current calendar view.
    internal private(set) var days: [Date] = []
    
    /// The system notification center.
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Computed Properties
    
    /// The formatted string for today's date.
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    /// The date to save for the task's target, or nil if not set.
    internal var saveTargetDate: Date? {
        hasDate ? targetDate : nil
    }
    
    /// The description for the currently selected time.
    internal var selectedTimeDescription: String {
        switch selectedTimeType {
        case .none:
            Texts.TaskManagement.DatePicker.Time.none
        case .value(_):
            selectedTime.fullHourMinutes
        }
    }
    
    /// The description for the currently selected notification(s).
    internal var selectedNotificationDescription: String {
        if notificationsLocal.isEmpty {
            return Texts.TaskManagement.DatePicker.Reminder.none
        } else {
            if notificationsLocal.count > 1 {
                return Texts.TaskManagement.DatePicker.Reminder.some
            } else {
                return notificationsLocal.first?.type.selectorName ?? Texts.TaskManagement.DatePicker.Reminder.error
            }
        }
    }
    
    /// The description for the currently selected repeating rule.
    internal var selectedRepeatingDescription: String {
        selectedRepeating.name
    }
    
    /// Returns the combined date and time for the task, based on current selections.
    ///
    /// - If no time is selected, returns the selected day.
    /// - If a time is selected, combines the selected day and selected time.
    internal var combinedDateTime: Date {
        // If no time is selected, just uses the selected day.
        guard selectedTimeType != .none else {
            hasTime = false
            hasDate = selectedDay != todayDate
            return selectedDay
        }
        // If a time is selected, combines the day and time components.
        hasTime = true
        hasDate = true
        
        let calendar = Calendar.current
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: selectedDay)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: selectedTime)
        // Combines day and time into a single Date.
        return calendar.date(from: DateComponents(
            year: dayComponents.year,
            month: dayComponents.month,
            day: dayComponents.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute,
            second: timeComponents.second
        )) ?? selectedDay
    }
    
    internal var accessToEdit: Bool {
        entity == nil || currentRole == .owner || currentRole == .edit
    }
    
    // MARK: - Initialization
    
    /// Initializes a new TaskManagementViewModel for a new or existing task.
    internal init(nameText: String = String(),
                  descriptionText: String = String(),
                  check: TaskCheck = .none,
                  targetDate: Date = .now.startOfDay,
                  hasEntity: Bool = false) {
        self.nameText = nameText
        self.descriptionText = descriptionText
        self.check = check
        
        self.targetDate = targetDate.startOfDay
        self.hasDate = targetDate != todayDate
        
        if hasDate {
            separateTargetDateToTimeAndDay(targetDate: targetDate)
        }
        updateDays()
        
        if let roleRaw = selectedMember?.role {
            self.selectedShareType = ShareAccess(rawValue: roleRaw) ?? .viewOnly
        } else {
            self.selectedShareType = .viewOnly
        }
    }
    
    /// Convenience initializer for editing an existing TaskEntity.
    internal convenience init(entity: TaskEntity) {
        self.init(hasEntity: true)
        self.entity = entity
        
        self.nameText = entity.name ?? String()
        self.descriptionText = entity.details ?? String()
        self.check = TaskCheck(rawValue: entity.completed) ?? .none
        
        self.targetDate = entity.target ?? .now.startOfDay
        self.hasDate = entity.target != nil
        self.hasTime = entity.hasTargetTime
        
        self.importance = entity.important
        self.pinned = entity.pinned
        
        separateTargetDateToTimeAndDay(targetDate: entity.target)
        setupChecklistLocal(entity.checklist)
        setupNotificationsLocal(entity.notifications)
    }
    
    // MARK: - Public Methods
    
    /// Disables the add task button glow, if currently enabled.
    internal func disableButtonGlow() {
        guard addTaskButtonGlow != false else { return }
        addTaskButtonGlow.toggle()
    }
    
    /// Reads the notification status from UserDefaults and updates local status.
    internal func readNotificationStatus() {
        let defaults = UserDefaults.standard
        let rawValue = defaults.string(forKey: Texts.UserDefaults.notifications) ?? String()
        notificationsStatus = NotificationStatus(rawValue: rawValue) ?? .prohibited
        if notificationsStatus != .allowed {
            notificationsLocal.removeAll()
        }
    }
    
    /// Move the calendar month forward or backward.
    internal func calendarMonthMove(for direction: CalendarMovement) {
        let value: Int
        switch direction {
        case .backward:
            value = -1
            calendarSwapDirection = .backward
        case .forward:
            value = 1
            calendarSwapDirection = .forward
        }
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: calendarDate) {
            calendarDate = newDate
        }
    }
    
    /// Toggles the main task check state (and checklist completion).
    internal func toggleTitleCheck() {
        switch check {
        case .none, .checked:
            self.check = .unchecked
            setChecklistCompletion(to: false)
        case .unchecked:
            self.check = .checked
            setChecklistCompletion(to: true)
        }
    }
    
    internal func toggleShowingNetworkErrorAlert() {
        showingNetworkErrorAlert.toggle()
    }
    
    internal func toggleShowingDeniedAlert() {
        showingDeniedAlert.toggle()
    }
    
    internal func toggleShowingStopSharingAlert() {
        showingStopSharingAlert.toggle()
    }
    
    /// Toggles the importance flag for the task.
    internal func toggleImportanceCheck() {
        importance.toggle()
    }
    
    /// Toggles the pinned flag for the task.
    internal func togglePinnedCheck() {
        pinned.toggle()
    }
    
    /// Toggles the removed flag.
    internal func toggleRemoved() {
        removed.toggle()
    }
    
    /// Sets the check state to unchecked.
    internal func setCheckFalse() {
        check = .unchecked
    }
    
    /// Toggles the bottom check state between .none and .unchecked.
    internal func toggleBottomCheck() {
        switch check {
        case .none:
            self.check = .unchecked
        case .unchecked, .checked:
            self.check = .none
        }
    }
    
    /// Shows or hides the share sheet.
    internal func toggleShareSheet() {
        showingShareSheet.toggle()
    }
    
    /// Shows or hides the date picker.
    internal func toggleDatePicker() {
        showingDatePicker.toggle()
    }
    
    /// Shows or hides the notification alert.
    internal func toggleShowingNotificationAlert() {
        showingNotificationAlert.toggle()
    }
    
    internal func toggleShowingRemoveMemberAlert() {
        showingRemoveMemberAlert.toggle()
    }
    
    /// Sets whether a date is shown for the task.
    internal func showDate(to show: Bool) {
        hasDate = show
    }
    
    /// Hides the date picker.
    internal func doneDatePicker() {
        showingDatePicker = false
    }
    
    /// Cancels any changes to the task date/time and restores from entity.
    internal func cancelTaskDateParams() {
        targetDate = entity?.target ?? .now.startOfDay
        hasDate = entity?.target != nil
        setupNotificationsLocal(entity?.notifications)
    }
    
    /// Saves the combined date/time as the task's target date.
    internal func saveTaskDateParams() {
        targetDate = combinedDateTime
        // Recalculate notification targets for updated date
        notificationsLocal = Set(notificationsLocal.map { item in
            var updatedItem = item
            updatedItem.target = notificationTargetCalculation(for: item.type)
            return updatedItem
        })
    }
    
    /// Schedules user notifications for the selected notification items.
    internal func setupUserNotifications(remove notifications: NSSet?) {
        guard notificationsStatus == .allowed else { return }
        notificationCenter.setupNotifications(for: notificationsLocal,
                                              remove: notifications,
                                              with: nameText)
    }
    
    /// Cancels the date picker.
    internal func cancelDatePicker() {
        showingDatePicker = false
    }
    
    /// Sets up available notifications for the current date/time and removes unavailable selections.
    internal func setupNotificationAvailability() {
        availableNotifications = TaskNotification.availableNotifications(
            for: combinedDateTime,
            hasTime: hasTime)
        deselectUnavailableNotifications()
    }
    
    /// Removes any notifications from the selection that are no longer valid.
    internal func deselectUnavailableNotifications() {
        let allowedTypes = Set(availableNotifications)
        notificationsLocal = notificationsLocal.filter { allowedTypes.contains($0.type) }
    }
    
    /// Toggles selection for a notification type. If not allowed, shows alert.
    internal func toggleNotificationSelection(for type: TaskNotification) {
        guard notificationsStatus == .allowed else {
            notificationsLocal.removeAll()
            type != .none ? showingNotificationAlert.toggle() : nil
            return
        }
        guard type != .none else {
            notificationsLocal.removeAll()
            return
        }
        let notification = NotificationItem(
            type: type,
            target: notificationTargetCalculation(for: type)
        )
        if let item = notificationsLocal.first(where: { $0.type == notification.type }) {
            notificationsLocal.remove(item)
            if let serverId = item.serverId, let entity = fetchNotificationEntity(with: serverId) {
                NotificationNetworkService.shared.deleteNotification(entity)
            }
        } else {
            notificationsLocal.insert(notification)
        }
    }
    
    /// Selects a repeating rule for the task.
    internal func toggleRepeatingSelection(for type: TaskRepeating) {
        selectedRepeating = type
    }
    
    /// Returns the menu label for a given TaskDateParam.
    internal func menuLabel(for type: TaskDateParam) -> String {
        switch type {
        case .time:
            selectedTimeDescription
        case .notifications:
            selectedNotificationDescription
        case .repeating:
            selectedRepeatingDescription
        case .endRepeating:
            Texts.TaskManagement.DatePicker.Repeat.noneEnd
        }
    }
    
    /// Returns whether to show the default icon for a menu param.
    internal func showingMenuIcon(for type: TaskDateParam) -> Bool {
        switch type {
        case .time:
            selectedTimeType == .none
        case .notifications:
            notificationsLocal.isEmpty
        case .repeating:
            selectedRepeating == .none
        case .endRepeating:
            true
        }
    }
    
    /// Removes the selection for a given parameter.
    internal func paramRemoveMethod(for type: TaskDateParam) {
        switch type {
        case .time:
            selectedTimeType = .none
            setupNotificationAvailability()
        case .notifications:
            notificationsLocal.removeAll()
        case .repeating:
            selectedRepeating = .none
        case .endRepeating:
            selectedRepeating = .none
        }
    }
    
    /// Removes all date/time/notification parameters.
    internal func allParamRemoveMethod() {
        selectedDay = .now.startOfDay
        calendarDate = .now.startOfDay
        paramRemoveMethod(for: .time)
        paramRemoveMethod(for: .notifications)
    }
    
    // MARK: - Checklist Management
    
    /// Adds a checklist item after the given id, or at the end if not found.
    internal func addChecklistItem(after id: UUID) {
        let index: Int
        if checklistLocal.count < 1 {
            index = 0
        } else {
            if let firstIndex = checklistLocal.firstIndex(where: { $0.id == id }) {
                index = firstIndex + 1
            } else {
                index = checklistLocal.count
            }
        }
        let newItem = ChecklistItem(name: checkListItemText, order: index)
        // Animates the insertion for user feedback.
        withAnimation(.bouncy(duration: 0.2)) {
            checklistLocal.insert(newItem, at: index)
        }
    }
    
    /// Appends a checklist item to the end.
    internal func appendChecklistItem() {
        checklistLocal.append(ChecklistItem(name: checkListItemText, order: checklistLocal.count))
    }
    
    /// Removes a checklist item by id, if more than one remains.
    internal func removeChecklistItem(for id: UUID) {
        guard checklistLocal.count > 1 else { return }
        if let index = checklistLocal.firstIndex(where: { $0.id == id }) {
            checklistLocal.remove(at: index)
        }
    }
    
    /// Sets up the local checklist from a given NSSet (from persistence).
    /// - Parameter checklist: The NSSet of ChecklistEntity (optional).
    internal func setupChecklistLocal(_ checklist: NSSet? = nil) {
        guard let checklistSet = checklist as? Set<ChecklistEntity> else { return }
        let checklistArray = checklistSet.sorted { $0.order < $1.order }
        checklistLocal.removeAll()
        for entity in checklistArray {
            let item = ChecklistItem(
                serverId: entity.serverId,
                name: entity.name ?? String(),
                completed: entity.completed,
                order: Int(entity.order))
            checklistLocal.append(item)
        }
    }
    
    internal func reloadChecklist(from checklist: NSSet?) {
        self.checklistLocal.removeAll()
        setupChecklistLocal(checklist)
    }
    
    internal func reloadNotifications(from notifications: NSSet?) {
        self.notificationsLocal.removeAll()
        setupNotificationsLocal(notifications)
    }
    
    /// Toggles completion for a checklist item, and moves to top if completed.
    /// - Parameter item: A binding to the checklist item.
    internal func toggleChecklistComplete(for item: Binding<ChecklistItem>) {
        item.wrappedValue.completed.toggle()
        if let index = checklistLocal.firstIndex(of: item.wrappedValue),
           item.wrappedValue.completed {
            // Animates completed item to top.
            withAnimation(.bouncy(duration: 0.2)) {
                let sourceItem = checklistLocal.remove(at: index)
                checklistLocal.insert(sourceItem, at: 0)
            }
        }
    }
    
    /// Removes the given checklist item.
    internal func removeChecklistItem(_ item: ChecklistItem) {
        if let sourceIndex = checklistLocal.firstIndex(of: item) {
            checklistLocal.remove(at: sourceIndex)
        }
        if let entity {
            ListItemNetworkService.deleteChecklistItem(item, for: entity)
        }
    }
    
    /// Sets the currently dragged checklist item.
    internal func setDraggingItem(for item: ChecklistItem?) {
        draggingItem = item
    }
    
    /// Handles dropping a dragged checklist item onto another.
    /// - Parameters:
    ///   - item: The item being targeted.
    ///   - status: Whether the drop is valid.
    internal func setDraggingTargetResult(for item: ChecklistItem, status: Bool) {
        if let draggingItem = draggingItem, status, draggingItem != item {
            if let sourceIndex = checklistLocal.firstIndex(of: draggingItem),
               let destinationIndex = checklistLocal.firstIndex(of: item) {
                // Animates reordering
                withAnimation(.bouncy(duration: 0.2)) {
                    let sourceItem = checklistLocal.remove(at: sourceIndex)
                    checklistLocal.insert(sourceItem, at: destinationIndex)
                }
            }
        }
    }
    
    // MARK: - Private Methods

    /// Persists the current shareMembers count to the TaskEntity.members and saves the context.
    private func persistMembersCount() {
        guard let task = self.entity, let context = task.managedObjectContext else { return }
        task.members = Int16(self.shareMembers.count)
        do {
            try context.save()
            logger.info("Persisted members count to TaskEntity: \(self.shareMembers.count)")
        } catch {
            logger.error("Failed to persist members count: \(error.localizedDescription)")
        }
    }
    
    /// Updates the days array for the current calendarDate.
    private func updateDays() {
        days = calendarDate.calendarDisplayDays
    }
    
    /// Sets completion for all checklist items.
    private func setChecklistCompletion(to active: Bool) {
        for index in checklistLocal.indices {
            checklistLocal[index].toggleCompleted(to: active)
        }
    }
    
    /// Splits a target date into selectedDay and selectedTime, updating UI state.
    private func separateTargetDateToTimeAndDay(targetDate: Date?) {
        guard let time = targetDate else { return }
        let calendar = Calendar.current
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: time)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        selectedDay = calendar.date(from: DateComponents(
            year: dayComponents.year,
            month: dayComponents.month,
            day: dayComponents.day
        )) ?? .now
        calendarDate = selectedDay
        
        guard hasTime else { return }
        selectedTime = calendar.date(from: DateComponents(
            hour: timeComponents.hour,
            minute: timeComponents.minute,
            second: timeComponents.second
        )) ?? .now
        
        selectedTimeType = .value(selectedTime)
    }
    
    /// Calculates the notification fire date for a given notification type.
    private func notificationTargetCalculation(for type: TaskNotification) -> Date? {
        switch type {
        case .none:
            return .distantPast
        case .inTime:
            return combinedDateTime
        case .fiveMinutesBefore:
            return Calendar.current.date(byAdding: .minute,
                                         value: -5,
                                         to: combinedDateTime)
        case .thirtyMinutesBefore:
            return Calendar.current.date(byAdding: .minute,
                                         value: -30,
                                         to: combinedDateTime)
        case .oneHourBefore:
            return Calendar.current.date(byAdding: .hour,
                                         value: -1,
                                         to: combinedDateTime)
        case .oneDayBefore:
            return Calendar.current.date(byAdding: .day,
                                         value: -1,
                                         to: combinedDateTime)
        }
    }
    
    /// Fetches a NotificationEntity by serverId from the current context.
    private func fetchNotificationEntity(with serverId: String) -> NotificationEntity? {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let request: NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "serverId == %@", serverId)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    /// Handles creation and sharing of a share link for the current task.
    @MainActor
    internal func handleShareLink(expiresAt: String? = nil, grantRole: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        guard let entity = self.entity else { return }
        let expiration: String
        if let expiresAt = expiresAt {
            expiration = expiresAt
        } else {
            // Default: 7 days ahead in ISO8601
            let date = Date().addingTimeInterval(7*24*3600)
            expiration = Date.iso8601DateFormatter.string(from: date)
        }
        ShareNetworkService.shared.createShareAndPresentSheet(for: entity, expiresAt: expiration, grantRole: grantRole) { result in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                logger.error("\(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    internal func setSelectedMember(to member: SharingMember?) {
        selectedMember = member
    }
    
    internal func setSharingTask(to task: TaskEntity?) {
        sharingTask = task
    }
    
    @MainActor
    internal func loadMembersForSharingTask(completion: @escaping ((Result<Void, Error>) -> Void)) {
        guard let task = entity,
              let serverId = task.serverId, !serverId.isEmpty
        else {
            completion(.success(()))
            return
        }
        
        let group = DispatchGroup()
        var capturedError: Error? = nil

        if task.role != ShareAccess.owner.rawValue {
            group.enter()
            ShareAccessService.shared.getMyRole(for: serverId) { [weak self] result in
                guard let self = self else { group.leave(); return }
                switch result {
                case .success(let role):
                    self.currentRole = ShareAccess(rawValue: role) ?? .viewOnly
                    task.role = role
                    if let context = task.managedObjectContext {
                        do {
                            try context.save()
                        } catch {
                            logger.error("Failed to save role to TaskEntity: \(error.localizedDescription)")
                        }
                    }
                    logger.info("Current user's share access role: \(role)")
                case .failure(let error):
                    self.currentRole = .viewOnly
                    logger.error("Error fetching my role: \(error.localizedDescription)")
                    if capturedError == nil { capturedError = error }
                }
                group.leave()
            }
        } else {
            self.currentRole = .owner
        }

        group.enter()
        ShareAccessService.shared.getMembers(for: serverId) { [weak self] result in
            switch result {
            case .success(let members):
                self?.shareMembers = members
                self?.persistMembersCount()
                self?.syncDeniedMembers()
            case .failure(let error):
                logger.error("Error fetching share members: \(error.localizedDescription)")
                self?.shareMembers = []
                self?.deniedMembers = []
                if capturedError == nil { capturedError = error }
            }
            group.leave()
        }

        group.notify(queue: .main) {
            if let error = capturedError {
                self.showingNetworkErrorAlert = true
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Loads members for the current sharing task and presents appropriate toasts based on the result.
    /// - Note: Wraps `loadMembersForSharingTask(completion:)` to provide user feedback.
    @MainActor
    internal func loadMembersForSharingTaskWithToasts() {
        guard let task = entity,
              let serverId = task.serverId, !serverId.isEmpty,
              let share = task.share, share.count > 0
        else {
            if entity?.role == nil || entity?.role == ShareAccess.owner.rawValue {
                self.currentRole = .owner
            } else {
                self.currentRole = .viewOnly
            }
            return
        }
        
        loadMembersForSharingTask { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                switch self.currentRole {
                case .viewOnly, .edit:
                    Toast.shared.present(title: self.currentRole.description)
                default:
                    break
                }
                
            case .failure(_):
                break
            }
        }
    }
    
    internal func isOwner(for member: SharingMember) -> Bool {
        member.role == ShareAccess.owner.rawValue
    }

    @MainActor
    func updateMemberRole(newRole: ShareAccess, onComplete: (() -> Void)? = nil) {
        guard let member = selectedMember else { return }
        guard selectedShareType.rawValue != selectedMember?.role else { onComplete?(); return }
        
        self.selectedShareType = newRole
        isUpdatingMemberRole = true
        ShareAccessService.shared.updateMemberRole(listId: member.listId, memberId: member.id, newRole: newRole.rawValue) { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.isUpdatingMemberRole = false
                switch result {
                case .success(let updatedMember):
                    if let index = self?.shareMembers.firstIndex(where: { $0.id == updatedMember.id }) {
                        self?.shareMembers[index] = updatedMember
                    }
                    self?.syncDeniedMembers()
                    self?.persistMembersCount()
                    onComplete?()
                case .failure(_):
                    self?.showingNetworkErrorAlert = true
                }
            }
        }
    }
    
    /// Deletes a sharing member from the list.
    @MainActor
    func deleteMember(_ member: SharingMember, onComplete: (() -> Void)? = nil) {
        guard let listId = entity?.serverId else { return }
        isUpdatingMemberRole = true
        ShareAccessService.shared.deleteMember(listId: listId, memberId: member.id) { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.isUpdatingMemberRole = false
                switch result {
                case .success:
                    guard let self = self else { return }
                    self.shareMembers.removeAll { $0.id == member.id }
                    if !self.deniedMembers.contains(where: { $0.id == member.id }) {
                        self.deniedMembers.append(member)
                    }
                    self.persistMembersCount()
                    onComplete?()
                case .failure(_):
                    self?.showingNetworkErrorAlert = true
                }
            }
        }
    }
    
    /// Moves any shareMembers with role == .closed to deniedMembers without duplication.
    internal func syncDeniedMembers() {
        let closedRoleRaw = ShareAccess.closed.rawValue
        let closedMembers = shareMembers.filter { $0.role == closedRoleRaw }
        let closedIds = Set(closedMembers.map { $0.id })
        let deniedIds = Set(deniedMembers.map { $0.id })
        let newDenied = closedMembers.filter { !deniedIds.contains($0.id) }
        deniedMembers.append(contentsOf: newDenied)
        shareMembers.removeAll { closedIds.contains($0.id) }
    }

    /// Adds all current shareMembers to deniedMembers without duplication.
    internal func addAllShareMembersToDenied() {
        let deniedIds = Set(deniedMembers.map { $0.id })
        let toAppend = shareMembers.filter { !deniedIds.contains($0.id) }
        if !toAppend.isEmpty {
            deniedMembers.append(contentsOf: toAppend)
            logger.info("Moved \(toAppend.count) members from shareMembers to deniedMembers")
        }
    }

    @MainActor
    func removeAllMembersAndLinks(onComplete: ((Result<Void, Error>) -> Void)? = nil) {
        guard let listId = entity?.serverId, !listId.isEmpty else {
            onComplete?(.success(()))
            return
        }
        isUpdatingMemberRole = true
        let group = DispatchGroup()
        var capturedError: Error? = nil

        // 1) Remove all current members
        group.enter()
        ShareAccessService.shared.getMembers(for: listId) { result in
            switch result {
            case .success(let members):
                for member in members {
                    group.enter()
                    ShareAccessService.shared.deleteMember(listId: listId, memberId: member.id) { deleteResult in
                        if case .failure(let error) = deleteResult {
                            if capturedError == nil { capturedError = error }
                            logger.error("Failed to delete member: \(member.id), error: \(error.localizedDescription)")
                        } else {
                            logger.info("Deleted member: \(member.id)")
                        }
                        group.leave()
                    }
                }
                group.leave()
            case .failure(let error):
                if capturedError == nil { capturedError = error }
                logger.error("Failed to load members for deletion: \(error.localizedDescription)")
                group.leave()
            }
        }

        // 2) Remove all share links
        group.enter()
        ShareNetworkService.shared.getShareInfo(for: listId) { result in
            switch result {
            case .success(let links):
                for link in links {
                    group.enter()
                    ShareNetworkService.shared.deleteShare(listId: listId, shareId: link.id) { deleteResult in
                        if case .failure(let error) = deleteResult {
                            if capturedError == nil { capturedError = error }
                            logger.error("Failed to delete share link: \(link.id), error: \(error.localizedDescription)")
                        } else {
                            logger.info("Deleted share link: \(link.id)")
                        }
                        group.leave()
                    }
                }
                group.leave()
            case .failure(let error):
                if capturedError == nil { capturedError = error }
                logger.error("Failed to load share links for deletion: \(error.localizedDescription)")
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.showingStopSharingAlert = false
            self.isUpdatingMemberRole = false
            if let error = capturedError {
                self.showingNetworkErrorAlert = true
                onComplete?(.failure(error))
            } else {
                self.addAllShareMembersToDenied()
                self.shareMembers.removeAll()
                self.persistMembersCount()
                if let task = self.entity, let context = task.managedObjectContext {
                    task.share = nil
                    do {
                        try context.save()
                        logger.info("Cleared local share links for task and saved context")
                    } catch {
                        logger.error("Failed to save context after clearing local share links: \(error.localizedDescription)")
                    }
                }
                Toast.shared.present(title: "\(Texts.TaskManagement.ShareView.StopSharingAlert.toastTitle) \(self.entity?.folder?.name ?? Texts.Folders.all)")
                onComplete?(.success(()))
            }
        }
    }
}

// MARK: - Notifications Management

extension TaskManagementViewModel {
    /// Sets up the local notifications from a given NSSet (from persistence).
    /// - Parameter notifications: The NSSet of NotificationEntity (optional).
    internal func setupNotificationsLocal(_ notifications: NSSet?) {
        guard let notificationsArray = notifications?.compactMap({ $0 as? NotificationEntity }) else { return }
        
        for notification in notificationsArray {
            guard let type = notification.type,
                  let target = notification.target
            else { continue }
            let itemType = TaskNotification(rawValue: type) ?? .inTime
            let item = NotificationItem(type: itemType,
                                        target: target,
                                        serverId: notification.serverId)
            notificationsLocal.insert(item)
        }
    }
}


