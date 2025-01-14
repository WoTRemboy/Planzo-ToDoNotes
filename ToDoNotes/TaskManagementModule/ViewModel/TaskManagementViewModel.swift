//
//  TaskManagementViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

final class TaskManagementViewModel: ObservableObject {
    
    @Published internal var nameText: String
    @Published internal var descriptionText: String
    @Published internal var check: Bool
    internal var entity: TaskEntity?
    
    init(nameText: String = String(),
         descriptionText: String = String(),
         check: Bool = false) {
        self.nameText = nameText
        self.descriptionText = descriptionText
        self.check = check
    }
    
    convenience init(entity: TaskEntity) {
        self.init()
        self.nameText = entity.name ?? String()
        self.descriptionText = entity.details ?? String()
        self.check = entity.completed != 0
    }
    
    internal func toggleCheck() {
        check.toggle()
    }
    
}
