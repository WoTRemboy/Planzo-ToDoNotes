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
