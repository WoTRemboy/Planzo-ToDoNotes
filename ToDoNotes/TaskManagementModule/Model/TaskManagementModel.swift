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
            Texts.TaskManagement.DatePicker.noneReminder
        case .inTime:
            Texts.TaskManagement.DatePicker.inTime
        case .fiveMinutesBefore:
            Texts.TaskManagement.DatePicker.fiveMinutesBefore
        case .thirtyMinutesBefore:
            Texts.TaskManagement.DatePicker.thirtyMinutesBefore
        case .oneHourBefore:
            Texts.TaskManagement.DatePicker.oneHourBefore
        case .oneDayBefore:
            Texts.TaskManagement.DatePicker.oneDayBefore
        }
    }
    
    internal var notificationName: String {
        switch self {
        case .none:
            String()
        case .inTime:
            Texts.TaskManagement.DatePicker.inTimeNotification
        case .fiveMinutesBefore:
            Texts.TaskManagement.DatePicker.fiveMinutesBeforeNotification
        case .thirtyMinutesBefore:
            Texts.TaskManagement.DatePicker.thirtyMinutesBeforeNotification
        case .oneHourBefore:
            Texts.TaskManagement.DatePicker.oneHourBeforeNotification
        case .oneDayBefore:
            Texts.TaskManagement.DatePicker.oneDayBeforeNotification
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
        
        return availableTypes
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
            Texts.TaskManagement.DatePicker.noneRepeating
        case .daily:
            Texts.TaskManagement.DatePicker.dailyRepeating
        case .weekly:
            Texts.TaskManagement.DatePicker.weeklyRepeating
        case .monthly:
            Texts.TaskManagement.DatePicker.monthlyRepeating
        case .yearly:
            Texts.TaskManagement.DatePicker.yearlyRepeating
        case .businessDays:
            Texts.TaskManagement.DatePicker.businessRepeating
        case .weekendDays:
            Texts.TaskManagement.DatePicker.weekendRepeating
        }
    }
}

enum TaskEndRepeating {
    case none
    // Add more later
    
    internal var name: String {
        switch self {
        case .none:
            Texts.TaskManagement.DatePicker.noneEndRepeating
        }
    }
}

enum CalendarMovement {
    case forward
    case backward
}
