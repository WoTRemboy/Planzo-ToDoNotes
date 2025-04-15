//
//  TaskManagementViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

final class TaskManagementViewModel: ObservableObject {
    
    internal var checklistItems: [ChecklistEntity] = []
    
    private(set) var notificationsStatus: NotificationStatus = .prohibited
    
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow) private var addTaskButtonGlow: Bool = false
    @AppStorage(Texts.UserDefaults.taskCreation) var taskCreationFullScreen: TaskCreation = .popup
    
    @Published internal var nameText: String
    @Published internal var descriptionText: String
    @Published internal var check: TaskCheck
    @Published internal var checklistLocal: [ChecklistItem] = []
    @Published internal var draggingItem: ChecklistItem? = nil
    
    @Published internal var checkListItemText: String = String()
    
    @Published internal var importance: Bool = false
    @Published internal var pinned: Bool = false
    @Published internal var removed: Bool = false
    
    @Published internal var showingShareSheet: Bool = false
    @Published internal var shareSheetHeight: CGFloat = 0
    
    @Published internal var targetDate: Date
    @Published internal var hasDate: Bool = false
    @Published internal var hasTime: Bool = false
    @Published internal var selectedDay: Date = .now.startOfDay
    @Published internal var selectedTime: Date = .now
    
    @Published internal var selectedTimeType: TaskTime = .none
    @Published internal var availableNotifications = [TaskNotification]()
    @Published internal var notificationsLocal: Set<NotificationItem> = []
    
    @Published internal var selectedRepeating: TaskRepeating = .none
    
    @Published internal var notificationsCheck: Bool = false
    @Published internal var showingDatePicker: Bool = false
    @Published internal var showingNotificationAlert: Bool = false
    
    private var entity: TaskEntity? = nil
    
    @Published internal var calendarDate: Date = Date.now {
        didSet {
            updateDays()
        }
    }
    
    internal let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    private(set) var calendarSwapDirection: CalendarMovement = .forward
    private(set) var todayDate: Date = Date.now.startOfDay
    private(set) var days: [Date] = []
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    internal var saveTargetDate: Date? {
        hasDate ? targetDate : nil
    }
    
    internal var selectedTimeDescription: String {
        switch selectedTimeType {
        case .none:
            Texts.TaskManagement.DatePicker.Time.none
        case .value(_):
            selectedTime.formatted(date: .omitted, time: .shortened)
        }
    }
    
    internal func disableButtonGlow() {
        guard addTaskButtonGlow != false else { return }
        addTaskButtonGlow.toggle()
    }
    
    internal func readNotificationStatus() {
        let defaults = UserDefaults.standard
        let rawValue = defaults.string(forKey: Texts.UserDefaults.notifications) ?? String()
        notificationsStatus = NotificationStatus(rawValue: rawValue) ?? .prohibited
        
        if notificationsStatus != .allowed {
            notificationsLocal.removeAll()
        }
    }
    
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
    
    internal var selectedRepeatingDescription: String {
        selectedRepeating.name
    }
    
    internal var combinedDateTime: Date {
        guard selectedTimeType != .none else {
            hasTime = false
            hasDate = selectedDay != todayDate
            return selectedDay
        }
        hasTime = true
        hasDate = true

        let calendar = Calendar.current
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: selectedDay)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: selectedTime)
        
        return calendar.date(from: DateComponents(
            year: dayComponents.year,
            month: dayComponents.month,
            day: dayComponents.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute,
            second: timeComponents.second
        )) ?? selectedDay
    }
    
    init(nameText: String = String(),
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
        
        if !hasEntity {
            setupEmptyChecklistLocal()
        }
        
        updateDays()
    }
    
    convenience init(entity: TaskEntity) {
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
    
    private func updateDays() {
        days = calendarDate.calendarDisplayDays
    }
    
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
    
    internal func toggleImportanceCheck() {
        importance.toggle()
    }
    
    internal func togglePinnedCheck() {
        pinned.toggle()
    }
    
    internal func toggleRemoved() {
        removed.toggle()
    }
    
    internal func setCheckFalse() {
        check = .unchecked
    }
    
    internal func toggleBottomCheck() {
        switch check {
        case .none:
            self.check = .unchecked
        case .unchecked, .checked:
            self.check = .none
        }
    }
    
    private func setChecklistCompletion(to active: Bool) {
        for index in checklistLocal.indices {
            checklistLocal[index].toggleCompleted(to: active)
        }
    }
    
    internal func toggleShareSheet() {
        showingShareSheet.toggle()
    }
    
    internal func toggleDatePicker() {
        showingDatePicker.toggle()
    }
    
    internal func toggleShowingNotificationAlert() {
        showingNotificationAlert.toggle()
    }
    
    internal func showDate(to show: Bool) {
        hasDate = show
    }
    
    internal func doneDatePicker() {
        showingDatePicker = false
    }
    
    internal func cancelTaskDateParams() {
        targetDate = entity?.target ?? .now.startOfDay
        hasDate = entity?.target != nil
        setupNotificationsLocal(entity?.notifications)
    }
    
    internal func saveTaskDateParams() {
        targetDate = combinedDateTime
    }
    
    internal func setupUserNotifications(remove notifications: NSSet?) {
        guard notificationsStatus == .allowed else { return }
        notificationCenter.setupNotifications(for: notificationsLocal,
                                              remove: notifications,
                                              with: nameText)
    }
    
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
    
    internal func cancelDatePicker() {
        showingDatePicker = false
    }
    
    internal func setupNotificationAvailability() {
        availableNotifications = TaskNotification.availableNotifications(
            for: combinedDateTime,
            hasTime: hasTime)
        deselectUnavailableNotifications()
    }
    
    internal func deselectUnavailableNotifications() {
        let allowedTypes = Set(availableNotifications)
        notificationsLocal = notificationsLocal.filter { allowedTypes.contains($0.type) }
    }
    
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
        let notification = NotificationItem(type: type,
                                            target: notificationTargetCalculation(for: type))
        
        if let item = notificationsLocal.first(where: { $0.type == notification.type }) {
            notificationsLocal.remove(item)
        } else {
            notificationsLocal.insert(notification)
        }
    }
    
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
    
    internal func toggleRepeatingSelection(for type: TaskRepeating) {
        selectedRepeating = type
    }
    
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
    
    internal func allParamRemoveMethod() {
        selectedDay = .now.startOfDay
        calendarDate = .now.startOfDay
        paramRemoveMethod(for: .time)
        paramRemoveMethod(for: .notifications)
    }
    
    // MARK: - Checklist Methods
    
    internal func addChecklistItem(after id: UUID) {
        let newItem = ChecklistItem(name: checkListItemText)
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
        
        withAnimation(.bouncy(duration: 0.2)) {
            checklistLocal.insert(newItem, at: index)
        }
    }
    
    internal func removeChecklistItem(for id: UUID) {
        guard checklistLocal.count > 1 else { return }
        if let index = checklistLocal.firstIndex(where: { $0.id == id }) {
            checklistLocal.remove(at: index)
        }
    }
    
    internal func setupChecklistLocal(_ checklist: NSOrderedSet? = []) {
        guard let checklistArray = checklist?.compactMap({ $0 as? ChecklistEntity }) else { return }
        
        for entity in checklistArray {
            let item = ChecklistItem(
                name: entity.name ?? String(),
                completed: entity.completed)
            checklistLocal.append(item)
        }
        setupEmptyChecklistLocal()
    }
    
    private func setupEmptyChecklistLocal() {
        if checklistLocal.isEmpty {
            let emptyItem = ChecklistItem(name: String())
            checklistLocal.append(emptyItem)
        }
    }
    
    internal func toggleChecklistComplete(for item: Binding<ChecklistItem>) {
        item.wrappedValue.completed.toggle()
        if let index = checklistLocal.firstIndex(of: item.wrappedValue),
           item.wrappedValue.completed {
            withAnimation(.bouncy(duration: 0.2)) {
                let sourceItem = checklistLocal.remove(at: index)
                checklistLocal.insert(sourceItem, at: 0)
            }
        }
    }
    
    internal func removeChecklistItem(_ item: ChecklistItem) {
        if let sourceIndex = checklistLocal.firstIndex(of: item) {
            checklistLocal.remove(at: sourceIndex)
        }
    }
    
    internal func setDraggingItem(for item: ChecklistItem?) {
        draggingItem = item
    }
    
    internal func setDraggingTargetResult(for item: ChecklistItem, status: Bool) {
        if let draggingItem = draggingItem, status, draggingItem != item {
            if let sourceIndex = checklistLocal.firstIndex(of: draggingItem),
               let destinationIndex = checklistLocal.firstIndex(of: item) {
                withAnimation(.bouncy(duration: 0.2)) {
                    let sourceItem = checklistLocal.remove(at: sourceIndex)
                    checklistLocal.insert(sourceItem, at: destinationIndex)
                }
            }
        }
    }
}

extension TaskManagementViewModel {
    
    internal func setupNotificationsLocal(_ notifications: NSSet?) {
        guard let notificationsArray = notifications?.compactMap({ $0 as? NotificationEntity }) else { return }
        
        for entity in notificationsArray {
            guard let type = entity.type,
                  let target = entity.target
            else { continue }
            
            let itemType = TaskNotification(rawValue: type) ?? .inTime
            let item = NotificationItem(type: itemType,
                                        target: target)
            notificationsLocal.insert(item)
        }
    }
}
