//
//  TaskManagementModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import Foundation

struct ChecklistItem: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var completed: Bool = false
    
    mutating internal func toggleCompleted(to active: Bool) {
        guard completed != active, !name.isEmpty else { return }
        self.completed = active
    }
}

struct NotificationItem: Identifiable, Equatable, Hashable {
    var id = UUID()
    var type: TaskNotification
    var target: Date?
}

enum ManagementView {
    case create
    case edit
}

enum TaskDateParam {
    case time
    case notifications
    case repeating
    case endRepeating
}

enum TaskTime: Equatable {
    case none
    case value(Date)
}

enum TaskNotification: String {
    case none = "task_notification_none"
    case inTime = "task_notification_inTime"
    case fiveMinutesBefore = "task_notification_fiveMinutesBefore"
    case thirtyMinutesBefore = "task_notification_thirtyMinutesBefore"
    case oneHourBefore = "task_notification_oneHourBefore"
    case oneDayBefore = "task_notification_oneDayBefore"
    
    static internal var allCases: [Self] {
        [.inTime, .fiveMinutesBefore, .thirtyMinutesBefore, .oneHourBefore, .oneDayBefore]
    }
    
    internal var sortOrder: Int {
        return Self.allCases.firstIndex(of: self) ?? Int.max
    }
    
    internal var selectorName: String {
        switch self {
        case .none:
            Texts.TaskManagement.DatePicker.Reminder.none
        case .inTime:
            Texts.TaskManagement.DatePicker.Reminder.inTime
        case .fiveMinutesBefore:
            Texts.TaskManagement.DatePicker.Reminder.fiveMinutesBefore
        case .thirtyMinutesBefore:
            Texts.TaskManagement.DatePicker.Reminder.thirtyMinutesBefore
        case .oneHourBefore:
            Texts.TaskManagement.DatePicker.Reminder.oneHourBefore
        case .oneDayBefore:
            Texts.TaskManagement.DatePicker.Reminder.oneDayBefore
        }
    }
    
    internal var notificationName: String {
        switch self {
        case .none:
            String()
        case .inTime:
            Texts.TaskManagement.DatePicker.Reminder.inTimeNotification
        case .fiveMinutesBefore:
            Texts.TaskManagement.DatePicker.Reminder.fiveMinutesBeforeNotification
        case .thirtyMinutesBefore:
            Texts.TaskManagement.DatePicker.Reminder.thirtyMinutesBeforeNotification
        case .oneHourBefore:
            Texts.TaskManagement.DatePicker.Reminder.oneHourBeforeNotification
        case .oneDayBefore:
            Texts.TaskManagement.DatePicker.Reminder.oneDayBeforeNotification
        }
    }
    
    static internal func availableNotifications(for target: Date?,
                                                hasTime: Bool) -> [Self] {
        guard let date = target else { return [.none] }
        
        let now = Date.now
        var availableTypes: [Self] = []
        
        if now < date {
            availableTypes.append(.inTime)
        }
        if now < date.addingTimeInterval(-5 * 60), hasTime {
            availableTypes.append(.fiveMinutesBefore)
        }
        if now < date.addingTimeInterval(-30 * 60), hasTime {
            availableTypes.append(.thirtyMinutesBefore)
        }
        if now < date.addingTimeInterval(-60 * 60), hasTime {
            availableTypes.append(.oneHourBefore)
        }
        if now < date.addingTimeInterval(-24 * 60 * 60) {
            availableTypes.append(.oneDayBefore)
        }
        
        return availableTypes.reversed()
    }
}

enum TaskRepeating {
    case none
    case daily
    case weekly
    case monthly
    case yearly
    case businessDays
    case weekendDays
    
    static internal var allCases: [Self] {
        [.daily, .weekly, .monthly, .yearly, .businessDays, .weekendDays]
    }
    
    internal var sortOrder: Int {
        Self.allCases.firstIndex(of: self) ?? Int.max
    }
    
    internal var name: String {
        switch self {
        case .none:
            Texts.TaskManagement.DatePicker.Repeat.none
        case .daily:
            Texts.TaskManagement.DatePicker.Repeat.daily
        case .weekly:
            Texts.TaskManagement.DatePicker.Repeat.weekly
        case .monthly:
            Texts.TaskManagement.DatePicker.Repeat.monthly
        case .yearly:
            Texts.TaskManagement.DatePicker.Repeat.yearly
        case .businessDays:
            Texts.TaskManagement.DatePicker.Repeat.business
        case .weekendDays:
            Texts.TaskManagement.DatePicker.Repeat.weekend
        }
    }
}

enum TaskEndRepeating {
    case none
    // Add more later
    
    internal var name: String {
        switch self {
        case .none:
            Texts.TaskManagement.DatePicker.Repeat.noneEnd
        }
    }
}

enum CalendarMovement {
    case forward
    case backward
}

enum TaskStatus {
    case none
    case outdated
    case important
    case outdatedImportant
    
    static internal func setupStatus(for entity: TaskEntity) -> Self {
        let isOutdated = (entity.completed == 1) &&
        entity.hasTargetTime &&
        ((entity.target ?? .distantPast) < Date.now)
        let isImportant = entity.important
        
        if isOutdated && isImportant {
            return .outdatedImportant
        } else if isOutdated {
            return .outdated
        } else if isImportant {
            return .important
        } else {
            return .none
        }
    }
}


enum TaskCheck: Int16 {
    case none = 0
    case unchecked = 1
    case checked = 2
}
