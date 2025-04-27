//
//  TaskSectionModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/18/25.
//

import Foundation

/// Represents the logical sections into which tasks can be categorized.
enum TaskSection: CaseIterable {
    case pinned
    case active
    case completed
    
    /// All possible task sections.
    internal var allCases: [Self] {
        return [.pinned, .active, .completed]
    }
    
    /// The localized name for each section.
    internal var name: String {
        switch self {
        case .pinned:
            Texts.CoreData.TaskSection.pinned
        case .active:
            Texts.CoreData.TaskSection.active
        case .completed:
            Texts.CoreData.TaskSection.completed
        }
    }
    
    /// Filters the sections that are present in the given dictionary keys.
    ///
    /// - Parameter keys: A collection of keys from a dictionary mapping `TaskSection` to `[TaskEntity]`.
    /// - Returns: An array of `TaskSection` values that exist in the given keys.
    static internal func availableRarities(for keys: Dictionary<Self, [TaskEntity]>.Keys) -> [Self] {
        return Self.allCases.filter { keys.contains($0) }
    }
}
