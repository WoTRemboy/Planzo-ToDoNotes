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

enum ManagementViewType {
    case create
    case edit
}

enum TaskDateParamType {
    case time
    case notifications
    case repeating
    case endRepeating
}

enum TaskTimeType: Equatable {
    case none
    case value(Date)
}

enum TaskNotificationsType {
    case none
    case inTime
    case fiveMinutesBefore
    case thirtyMinutesBefore
    case oneHourBefore
    case oneDayBefore
    
    static internal var allCases: [Self] {
        [.inTime, .fiveMinutesBefore, .thirtyMinutesBefore, .oneHourBefore, .oneDayBefore]
    }
    
    internal var sortOrder: Int {
        return Self.allCases.firstIndex(of: self) ?? Int.max
    }
    
    internal var name: String {
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
}

enum TaskRepeatingType {
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

enum TaskEndRepeatingType {
    case none
    // Add more later
    
    internal var name: String {
        switch self {
        case .none:
            Texts.TaskManagement.DatePicker.noneEndRepeating
        }
    }
}
