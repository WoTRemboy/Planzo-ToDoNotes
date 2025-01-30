//
//  TaskManagementViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

final class TaskManagementViewModel: ObservableObject {
    
    internal var entity: TaskEntity?
    internal var checklistItems: [ChecklistEntity] = []
    
    @AppStorage(Texts.UserDefaults.notifications) private var notificationsStatus: NotificationStatus = .prohibited
    
    @Published internal var nameText: String
    @Published internal var descriptionText: String
    @Published internal var check: Bool
    @Published internal var checklistLocal: [ChecklistItem] = []
    
    @Published internal var checkListItemText: String = String()
    
    @Published internal var showingShareSheet: Bool = false
    @Published internal var shareSheetHeight: CGFloat = 0
    

    @Published internal var targetDate: Date = .now
    @Published internal var hasDate: Bool = false
    @Published internal var hasTime: Bool = false
    @Published internal var selectedDay: Date = .now.startOfDay
    @Published internal var selectedTime: Date = .now
    
    @Published internal var selectedTimeType: TaskTimeType = .none
    @Published internal var selectedNotifications: Set<TaskNotificationsType> = []
    @Published internal var selectedRepeating: TaskRepeatingType = .none
    
    @Published internal var notificationsCheck: Bool = false
    @Published internal var targetDateSelected: Bool = false
    @Published internal var showingDatePicker: Bool = false
    
    internal let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    private(set) var todayDate: Date = Date.now.startOfDay
    private(set) var days: [Date] = []
    
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    internal var saveTargetDate: Date? {
        hasDate ? targetDate : nil
    }
    
    internal var selectedTimeDescription: String {
        switch selectedTimeType {
        case .none:
            Texts.TaskManagement.DatePicker.noneTime
        case .value(_):
            selectedTime.formatted(date: .omitted, time: .shortened)
        }
    }
    
    internal var selectedNotificationDescription: String {
        if selectedNotifications.isEmpty {
            return Texts.TaskManagement.DatePicker.noneReminder
        } else {
            return selectedNotifications
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { $0.name }
                .joined(separator: ", ")
        }
    }
    
    internal var selectedRepeatingDescription: String {
        selectedRepeating.name
    }
    
    private var combinedDateTime: Date {
        guard selectedTimeType != .none else {
            hasTime = false
            hasDate = selectedDay != todayDate
            return selectedDay
        }
        hasTime = true
        hasDate = true
        check = true

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
         check: Bool = false) {
        self.nameText = nameText
        self.descriptionText = descriptionText
        self.check = check
        updateDays()
    }
    
    convenience init(entity: TaskEntity) {
        self.init()
        self.nameText = entity.name ?? String()
        self.descriptionText = entity.details ?? String()
        self.check = entity.completed != 0
        self.targetDate = entity.target ?? .now.startOfDay
        self.hasDate = entity.target != nil
        self.hasTime = entity.hasTargetTime
        self.notificationsCheck = entity.notify
        self.targetDateSelected = entity.target != nil
        
        separateTargetDateToTimeAndDay(targetDate: entity.target)
        setupChecklistLocal(entity.checklist)
    }
    
    internal func updateDays() {
        days = todayDate.calendarDisplayDays
    }
    
    internal func toggleCheck() {
        check.toggle()
    }
    
    internal func toggleShareSheet() {
        showingShareSheet.toggle()
    }
    
    internal func toggleDatePicker() {
        showingDatePicker.toggle()
    }
    
    internal func showDate(to show: Bool) {
        hasDate = show
    }
    
    internal func doneDatePicker() {
        targetDateSelected = true
        check = true
        showingDatePicker = false
    }
    
    internal func saveTaskDateParams() {
        targetDate = combinedDateTime
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
        
        guard hasTime else { return }
        
        selectedTime = calendar.date(from: DateComponents(
            hour: timeComponents.hour,
            minute: timeComponents.minute,
            second: timeComponents.second
        )) ?? .now
        
        selectedTimeType = .value(selectedTime)
    }
    
    internal func cancelDatePicker() {
        targetDateSelected = false
        showingDatePicker = false
    }
    
    internal func toggleNotificationSelection(for type: TaskNotificationsType) {
        guard type != .none else {
            selectedNotifications.removeAll()
            return
        }
        
        if selectedNotifications.contains(type) {
            selectedNotifications.remove(type)
        } else {
            selectedNotifications.insert(type)
        }
    }
    
    internal func toggleRepeatingSelection(for type: TaskRepeatingType) {
        selectedRepeating = type
    }
    
    internal func menuLabel(for type: TaskDateParamType) -> String {
        switch type {
        case .time:
            selectedTimeDescription
        case .notifications:
            selectedNotificationDescription
        case .repeating:
            selectedRepeatingDescription
        case .endRepeating:
            Texts.TaskManagement.DatePicker.noneEndRepeating
        }
    }
    
    internal func showingMenuIcon(for type: TaskDateParamType) -> Bool {
        switch type {
        case .time:
            selectedTimeType == .none
        case .notifications:
            selectedNotifications.isEmpty
        case .repeating:
            selectedRepeating == .none
        case .endRepeating:
            true
        }
    }
    
    internal func paramRemoveMethod(for type: TaskDateParamType) {
        switch type {
        case .time:
            selectedTimeType = .none
        case .notifications:
            selectedNotifications.removeAll()
        case .repeating:
            selectedRepeating = .none
        case .endRepeating:
            selectedRepeating = .none
        }
    }
    
    internal func allParamRemoveMethod() {
        selectedDay = .now.startOfDay
        selectedTimeType = .none
        selectedNotifications.removeAll()
        selectedRepeating = .none
        selectedRepeating = .none
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
        
        withAnimation(.easeInOut(duration: 0.2)) {
            checklistLocal.insert(newItem, at: index)
        }
    }
    
    internal func removeChecklistItem(for id: UUID) {
        guard checklistLocal.count > 1 else { return }
        if let index = checklistLocal.firstIndex(where: { $0.id == id }) {
            checklistLocal.remove(at: index)
        }
    }
    
    internal func setupChecklistLocal(_ checklist: NSOrderedSet?) {
        guard let checklistArray = checklist?.compactMap({ $0 as? ChecklistEntity }) else { return }
        
        for entity in checklistArray {
            let item = ChecklistItem(
                name: entity.name ?? String(),
                completed: entity.completed)
            checklistLocal.append(item)
        }
        
        if checklistLocal.isEmpty {
            let emptyItem = ChecklistItem(name: String())
            checklistLocal.append(emptyItem)
        }
    }
}

extension TaskManagementViewModel {
    internal func notificationSetup(for task: TaskEntity) {
        guard let id = task.id,
              let name = task.name,
              let targetDate = task.target,
              notificationsStatus == .allowed
        else {
            return
        }
        notificationRemove(for: id)
        
        let content = UNMutableNotificationContent()
        content.title = Texts.Notifications.now
        content.body = name
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification setup error: \(error.localizedDescription)")
            } else {
                print("Notification successfully setup for \(name) at \(targetDate)")
            }
        }
    }

    internal func notificationRemove(for id: UUID?) {
        guard let id = id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
