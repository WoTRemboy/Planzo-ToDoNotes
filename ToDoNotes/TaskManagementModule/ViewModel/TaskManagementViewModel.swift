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
    @Published internal var selectedDate: Date = .now
    @Published internal var hasDate: Bool = false
    
    @Published internal var selectedNotifications: Set<TaskNotificationsType> = []
    @Published internal var notificationsCheck: Bool = false
    @Published internal var targetDateSelected: Bool = false
    @Published internal var showingDatePicker: Bool = false
    
    internal let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    private(set) var todayDate: Date = Date.now
    private(set) var days: [Date] = []
    
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    internal var saveTargetDate: Date? {
        hasDate ? targetDate : nil
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
        self.targetDate = entity.target ?? .now
        self.hasDate = entity.target != nil
        self.notificationsCheck = entity.notify
        self.targetDateSelected = entity.target != nil
        
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
