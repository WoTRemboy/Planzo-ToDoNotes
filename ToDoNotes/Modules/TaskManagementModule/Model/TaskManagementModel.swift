//
//  TaskManagementModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import Foundation
import CoreTransferable

// MARK: - Checklist Item Model

/// A model representing an individual checklist item inside a task.
struct ChecklistItem: Identifiable, Equatable, Codable, Transferable {
    var id = UUID()
    var serverId: String?
    var name: String
    var completed: Bool = false
    var order: Int
    
    /// Toggles the completed state of the checklist item if the new value is different and the name is not empty.
    /// - Parameter active: Boolean indicating the new completed state.
    mutating internal func toggleCompleted(to active: Bool) {
        guard completed != active, !name.isEmpty else { return }
        self.completed = active
    }
    
    /// Defines how a `ChecklistItem` can be transferred across views (drag and drop).
    static internal var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: ChecklistItem.self, contentType: .init(exportedAs: "com.avoqode.checklistitem"))
    }
}

// MARK: - Notification Item Model

/// Represents a notification related to a task, linked by type and optional trigger date.
struct NotificationItem: Identifiable, Equatable, Hashable {
    var id = UUID()
    var type: TaskNotification
    var target: Date?
    var serverId: String?
}

// MARK: - Management View State

/// Indicates whether the task management screen is in creation or editing mode.
enum ManagementView {
    case create
    case edit
}

// MARK: - Task Date Configuration Parameters

/// Represents different aspects of the task's date that can be configured by the user.
enum TaskDateParam {
    case time
    case notifications
    case repeating
    case endRepeating
}

// MARK: - Task Time Wrapper

/// A wrapper representing either the absence of a specific time value.
enum TaskTime: Equatable {
    case none
    case value(Date)
}

// MARK: - Task Notification Type

/// Defines possible types of notifications that can be attached to a task.
enum TaskNotification: String {
    case none = "task_notification_none"
    case inTime = "task_notification_inTime"
    case fiveMinutesBefore = "task_notification_fiveMinutesBefore"
    case thirtyMinutesBefore = "task_notification_thirtyMinutesBefore"
    case oneHourBefore = "task_notification_oneHourBefore"
    case oneDayBefore = "task_notification_oneDayBefore"
    
    /// All available notifications except `.none`.
    static internal var allCases: [Self] {
        [.inTime, .fiveMinutesBefore, .thirtyMinutesBefore, .oneHourBefore, .oneDayBefore]
    }
    
    /// Sort order index for display.
    internal var sortOrder: Int {
        return Self.allCases.firstIndex(of: self) ?? Int.max
    }
    
    /// The localized title used when showing this type in a selector UI.
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
    
    /// The internal name for a notification, used for system registration.
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
    
    /// Returns a filtered list of available notification types based on a target date and whether the task has a time set.
    /// - Parameters:
    ///   - target: Target date for the notification.
    ///   - hasTime: Whether the task is time-specific.
    /// - Returns: List of available notification types.
    static internal func availableNotifications(for target: Date?, hasTime: Bool) -> [Self] {
        guard let date = target else { return [.none] }
        
        let now = Date.now
        var availableTypes: [Self] = []
        
        if now < date {
            availableTypes.append(.inTime)              // In time
        }
        if now < date.addingTimeInterval(-5 * 60), hasTime {
            availableTypes.append(.fiveMinutesBefore)   // 5 minutes before
        }
        if now < date.addingTimeInterval(-30 * 60), hasTime {
            availableTypes.append(.thirtyMinutesBefore) // 30 minutes before
        }
        if now < date.addingTimeInterval(-60 * 60), hasTime {
            availableTypes.append(.oneHourBefore)       // 1 hour before
        }
        if now < date.addingTimeInterval(-24 * 60 * 60) {
            availableTypes.append(.oneDayBefore)        // 1 day before
        }
        
        return availableTypes.reversed()
    }
}

// MARK: - Task Repeating Types

/// Specifies different repeat schedules that a task can have.
enum TaskRepeating {
    case none
    case daily
    case weekly
    case monthly
    case yearly
    case businessDays
    case weekendDays
    
    /// All available repeating cases except `.none`.
    static internal var allCases: [Self] {
        [.daily, .weekly, .monthly, .yearly, .businessDays, .weekendDays]
    }
    
    /// Sort order index for display.
    internal var sortOrder: Int {
        Self.allCases.firstIndex(of: self) ?? Int.max
    }
    
    /// Localized display name for the repeat schedule.
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

// MARK: - Task End Repeating (Future-Expandable)

/// Represents the end condition for a repeating task.
enum TaskEndRepeating {
    case none
    // Add more later
    
    /// Localized name for the end repeat setting.
    internal var name: String {
        switch self {
        case .none:
            Texts.TaskManagement.DatePicker.Repeat.noneEnd
        }
    }
}

// MARK: - Calendar Movement

/// Represents the user's intent to navigate the calendar forward or backward.
enum CalendarMovement {
    case forward
    case backward
}

// MARK: - Task Status Calculation

/// Logical status of a task based on its attributes (used for UI, sorting).
enum TaskStatus {
    case none
    case outdated
    case important
    case outdatedImportant
    
    /// Calculates the current status of a task based on importance and whether it is outdated.
    /// - Parameter entity: The task entity to evaluate.
    /// - Returns: Appropriate `TaskStatus` value.
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

// MARK: - Task Checklist State

/// States for checklist items within a task (none, unchecked, checked).
enum TaskCheck: Int16 {
    case none = 0
    case unchecked = 1
    case checked = 2
}

enum ShareAccess: String {
    case viewOnly = "VIEWER"
    case edit = "EDITOR"
    
    internal var name: String {
        switch self {
        case .viewOnly:
            return Texts.TaskManagement.ShareView.view
        case .edit:
            return Texts.TaskManagement.ShareView.edit
        }
    }
}
