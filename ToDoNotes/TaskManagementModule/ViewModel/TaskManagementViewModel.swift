//
//  TaskManagementViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

final class TaskManagementViewModel: ObservableObject {
    
    internal var entity: TaskEntity?
    internal var checklistItems: [ChecklistEntity] = []
    
    @Published internal var nameText: String
    @Published internal var descriptionText: String
    @Published internal var check: Bool
    @Published internal var checklistLocal: [ChecklistItem] = []
    
    @Published internal var lastAddedItemID: UUID?
    @Published internal var newItemText: String = String()
    @Published internal var checkListItemText: String = String()
    
    @Published internal var showingShareSheet: Bool = false
    @Published internal var shareSheetHeight: CGFloat = 0
    
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
        
        setupChecklistLocal(entity.checklist)
    }
    
    internal func toggleCheck() {
        check.toggle()
    }
    
    internal func toggleShareSheet() {
        showingShareSheet.toggle()
    }
    
    internal func addChecklistItem() {
        guard !newItemText.isEmpty else { return }
                
        let newItem = ChecklistItem(name: newItemText)
        checklistLocal.append(newItem)
        lastAddedItemID = newItem.id
                
        newItemText = ""
    }
    
    internal func setupChecklistLocal(_ checklist: NSOrderedSet?) {
        guard let checklistArray = checklist?.compactMap({ $0 as? ChecklistEntity }) else { return }
        
        for entity in checklistArray {
            let item = ChecklistItem(
                name: entity.name ?? String(),
                completed: entity.completed)
            checklistLocal.append(item)
        }
    }
}
