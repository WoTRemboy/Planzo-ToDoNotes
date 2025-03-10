//
//  TaskSectionModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/18/25.
//

import Foundation

enum TaskSection: CaseIterable {
    case pinned
    case active
    case completed
    
    internal var allCases: [Self] {
        return [.pinned, .active, .completed]
    }
    
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
    
    static internal func availableRarities(for keys: Dictionary<Self, [TaskEntity]>.Keys) -> [Self] {
        return Self.allCases.filter { keys.contains($0) }
    }
}
