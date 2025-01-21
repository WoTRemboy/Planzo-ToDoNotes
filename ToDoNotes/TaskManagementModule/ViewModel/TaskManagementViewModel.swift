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
    
    @Published internal var checkListItemText: String = String()
    
    @Published internal var showingShareSheet: Bool = false
    @Published internal var shareSheetHeight: CGFloat = 0
    
    @Published internal var targetDate: Date = .now
    @Published internal var notificationsCheck: Bool = false
    @Published internal var targetDateSelected: Bool = false
    @Published internal var showingDatePicker: Bool = false
    
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
        self.targetDate = entity.target ?? .now
        self.notificationsCheck = entity.notify
        self.targetDateSelected = entity.target != nil
        
        setupChecklistLocal(entity.checklist)
    }
    
    internal var saveTargetDate: Date? {
        targetDateSelected ? targetDate : nil
    }
    
    internal func toggleCheck() {
        check.toggle()
    }
    
    internal func toggleShareSheet() {
        showingShareSheet.toggle()
    }
    
    internal func toggleDatePicker() {
        showingDatePicker.toggle()
    }
    
    internal func doneDatePicker() {
        targetDateSelected = true
        check = true
        showingDatePicker = false
    }
    
    internal func cancelDatePicker() {
        targetDateSelected = false
        showingDatePicker = false
    }
    
    // MARK: - Checklist Methods
    
    internal func addChecklistItem(after id: UUID) {
        let newItem = ChecklistItem(name: checkListItemText)
        let index: Int
        
        if checklistLocal.count < 1 {
            index = 0
        } else {
            if let firstIndex = checklistLocal.firstIndex(where: { $0.id == id }) {
                index = firstIndex + 1
            } else {
                index = checklistLocal.count
            }
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            checklistLocal.insert(newItem, at: index)
        }
    }
    
    internal func removeChecklistItem(for id: UUID) {
        guard checklistLocal.count > 1 else { return }
        if let index = checklistLocal.firstIndex(where: { $0.id == id }) {
            checklistLocal.remove(at: index)
        }
    }
    
    internal func setupChecklistLocal(_ checklist: NSOrderedSet?) {
        guard let checklistArray = checklist?.compactMap({ $0 as? ChecklistEntity }) else { return }
        
        for entity in checklistArray {
            let item = ChecklistItem(
                name: entity.name ?? String(),
                completed: entity.completed)
            checklistLocal.append(item)
        }
        
        if checklistLocal.isEmpty {
            let emptyItem = ChecklistItem(name: String())
            checklistLocal.append(emptyItem)
        }
    }
}
