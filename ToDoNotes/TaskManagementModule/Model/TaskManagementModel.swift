//
//  TaskManagementModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import Foundation

struct ChecklistItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var isChecked: Bool = false
}

enum ManagementViewType {
    case create
    case edit
}
