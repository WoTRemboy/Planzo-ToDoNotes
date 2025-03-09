//
//  TaskService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import Foundation
import CoreData

final class TaskService {
    
    static private var viewContext: NSManagedObjectContext {
        CoreDataProvider.shared.persistentContainer.viewContext
    }
    
    static private func save() throws {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
    
    static func saveTask(name: String,
                         description: String,
                         completeCheck: TaskCheck,
                         target: Date?,
                         hasTime: Bool,
                         importance: Bool,
                         pinned: Bool,
                         notifications: Set<NotificationItem>,
                         checklist: [ChecklistItem] = []) throws {
        
        let task = TaskEntity(context: viewContext)
        
        task.id = UUID()
        task.name = name
        task.details = description
        task.completed = completeCheck.rawValue
        
        task.created = .now
        task.target = target
        task.hasTargetTime = hasTime
        
        task.important = importance
        task.pinned = pinned
        
        var notificationEntities = [NotificationEntity]()
        for item in notifications {
            let entityItem = NotificationEntity(context: viewContext)
            entityItem.id = item.id
            entityItem.type = item.type.rawValue
            entityItem.target = item.target
            notificationEntities.append(entityItem)
        }
        let notificationsSet = NSSet(array: notificationEntities)
        task.addToNotifications(notificationsSet)
        //task.notifications = notificationsSet
        
        var checklistEnities = [ChecklistEntity]()
        for item in checklist {
            let entityItem = ChecklistEntity(context: viewContext)
            entityItem.name = item.name
            entityItem.completed = item.completed
            checklistEnities.append(entityItem)
        }
        let orderedChecklist = NSOrderedSet(array: checklistEnities)
        task.addToChecklist(orderedChecklist)
        //task.checklist = orderedChecklist
        
        try save()
    }
    
    static func deleteRemovedTask(for entity: TaskEntity) throws {
        viewContext.delete(entity)
        try save()
    }
    
    static func deleteRemovedTasks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Texts.CoreData.entity)
        fetchRequest.predicate = NSPredicate(format: "removed == %@", NSNumber(value: true))
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            if let result = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
               let objectIDs = result.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
            }
            viewContext.reset()
            try save()
        } catch {
            print("Error deleting removed tasks: \(error.localizedDescription)")
        }
    }
    
    static func getNotificationsByTask(task: TaskEntity) -> NSFetchRequest<NotificationEntity> {
        let request = NotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "task == %@", task)
        return request
    }
}


extension TaskService {
    
    // MARK: - Status Check Methods
    
    static func taskCheckStatus(for entity: TaskEntity) -> Bool {
        entity.completed == 2
    }
    
    static func taskCheckImportant(for entity: TaskEntity) -> Bool {
        entity.important
    }
    
    static func taskCheckPinned(for entity: TaskEntity) -> Bool {
        entity.pinned
    }
    
    // MARK: - Status Change Methods
    
    static func toggleImportant(for task: TaskEntity) throws {
        task.important.toggle()
        try save()
    }
    
    static func togglePinned(for task: TaskEntity) throws {
        task.pinned.toggle()
        try save()
    }
    
    static func toggleRemoved(for task: TaskEntity) throws {
        task.removed.toggle()
        try save()
    }
}
