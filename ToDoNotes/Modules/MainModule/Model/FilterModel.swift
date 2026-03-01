//
//  FilterModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

/// Represents different types of task filters.
enum Filter: CaseIterable {
    case active
    case outdated
    case unsorted
    case completed
    case archived
    case deleted
    
    /// A customized list of filters that should appear in the UI.
    static internal var allCases: [Self] {
        [.active, .outdated, .completed, .archived, .deleted]
    }
    
    /// Returns the user-facing localized name of the filter.
    internal var name: String {
        switch self {
        case .active:
            return Texts.MainPage.Filter.active
        case .outdated:
            return Texts.MainPage.Filter.outdate
        case .unsorted:
            return Texts.MainPage.Filter.unsorted
        case .completed:
            return Texts.MainPage.Filter.completed
        case .archived:
            return Texts.MainPage.Filter.archived
        case .deleted:
            return Texts.MainPage.Filter.deleted
        }
    }

    /// Returns the SF Symbol name representing the filter.
    internal var systemImageName: String {
        switch self {
        case .active:
            return "bolt.circle"
        case .outdated:
            return "clock.badge.exclamationmark"
        case .unsorted:
            return "tray"
        case .completed:
            return "checkmark.circle"
        case .archived:
            return "archivebox"
        case .deleted:
            return "trash"
        }
    }
}
