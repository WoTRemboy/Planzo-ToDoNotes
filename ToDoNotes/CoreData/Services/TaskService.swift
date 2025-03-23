//
//  TaskService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import Foundation
import CoreData
import UserNotifications

final class TaskService {
    
    static private var viewContext: NSManagedObjectContext {
        CoreDataProvider.shared.persistentContainer.viewContext
    }
    
    static private func save() throws {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
    
    static func saveTask(entity: TaskEntity? = nil,
                         name: String,
                         description: String,
                         completeCheck: TaskCheck,
                         target: Date?,
                         hasTime: Bool,
                         folder: Folder? = nil,
                         importance: Bool,
                         pinned: Bool,
                         removed: Bool = false,
                         notifications: Set<NotificationItem>,
                         checklist: [ChecklistItem] = []) throws {
        
        guard !name.isEmpty || !description.isEmpty || checklist.count > 1 else { return }
        
        let task = entity ?? TaskEntity(context: viewContext)
        if entity == nil {
            task.id = UUID()
            task.created = .now
        }
        
        task.name = name
        task.details = description
        task.completed = completeCheck.rawValue
        
        task.target = target
        task.hasTargetTime = hasTime
        
        task.important = importance
        task.pinned = pinned
        task.removed = removed
        
        var notificationEntities = [NotificationEntity]()
        for item in notifications {
            let entityItem = NotificationEntity(context: viewContext)
            entityItem.id = item.id
            entityItem.type = item.type.rawValue
            entityItem.target = item.target
            notificationEntities.append(entityItem)
        }
        let notificationsSet = NSSet(array: notificationEntities)
        task.notifications = notificationsSet
        
        var checklistEnities = [ChecklistEntity]()
        for item in checklist {
            let entityItem = ChecklistEntity(context: viewContext)
            entityItem.name = item.name
            entityItem.completed = item.completed
            checklistEnities.append(entityItem)
        }
        let orderedChecklist = NSOrderedSet(array: checklistEnities)
        task.checklist = orderedChecklist
        
        guard entity == nil else {
            try save()
            return
        }
        if let folder {
            task.folder = folder.rawValue
        } else if !notifications.isEmpty {
            task.folder = Folder.reminders.rawValue
        } else if completeCheck != .none {
            task.folder = Folder.tasks.rawValue
        } else if checklist.count > 1 {
            task.folder = Folder.lists.rawValue
        } else {
            task.folder = Folder.other.rawValue
        }
        
        try save()
    }
    
    static func duplicate(task: TaskEntity?) throws {
        guard let task else { return }
        
        let newTask = TaskEntity(context: viewContext)
        newTask.id = UUID()
        newTask.created = task.created
        
        newTask.name = task.name
        newTask.details = task.details
        newTask.completed = task.completed
        newTask.target = task.target
        newTask.hasTargetTime = task.hasTargetTime
        newTask.important = task.important
        newTask.pinned = task.pinned
        newTask.removed = task.removed
        newTask.folder = task.folder
        
        if let notificationsSet = task.notifications as? Set<NotificationEntity> {
            var newNotifications = [NotificationEntity]()
            for notification in notificationsSet {
                let newNotification = NotificationEntity(context: viewContext)
                newNotification.id = UUID()
                newNotification.type = notification.type
                newNotification.target = notification.target
                newNotifications.append(newNotification)
            }
            newTask.notifications = NSSet(array: newNotifications)
        }
        
        if let checklistArray = task.checklist?.array as? [ChecklistEntity] {
            var newChecklist = [ChecklistEntity]()
            for checklistItem in checklistArray {
                let newItem = ChecklistEntity(context: viewContext)
                newItem.name = checklistItem.name
                newItem.completed = checklistItem.completed
                newChecklist.append(newItem)
            }
            newTask.checklist = NSOrderedSet(array: newChecklist)
        }
        
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
    
    static func deleteAllTasksAndClearNotifications(completion: ((Bool) -> Void)? = nil) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Texts.CoreData.entity)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            if let result = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
               let objectIDs = result.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
            }
            viewContext.reset()
            completion?(true)
        } catch {
            print("Batch delete error: \(error.localizedDescription)")
            completion?(false)
        }
    }
    
    static func getNotificationsByTask(task: TaskEntity) -> NSFetchRequest<NotificationEntity> {
        let request = NotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "task == %@", task)
        return request
    }
    
    static func getTasksBySearchTerm(_ searchTerm: String) -> NSFetchRequest<TaskEntity> {
        let request = TaskEntity.fetchRequest()
        request.sortDescriptors = []
        if !searchTerm.isEmpty {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchTerm)
        } else {
            request.predicate = nil
        }
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
    
    static func haveTextContent(for entity: TaskEntity) -> Bool {
        let details = entity.details ?? String()
        
        let firstChecklistElement = entity.checklist?.compactMap({ $0 as? ChecklistEntity }).first
        let firstChecklistName = firstChecklistElement?.name ?? String()
        let checklistCount = entity.checklist?.count ?? 0

        return !details.isEmpty || (!firstChecklistName.isEmpty || checklistCount > 1)
    }
    
    // MARK: - Status Change Methods
    
    static func toggleCompleteChecking(for task: TaskEntity) throws {
        task.completed = task.completed == 1 ? 2 : 1
        if task.completed == 2 {
            UNUserNotificationCenter.current().removeNotifications(for: task.notifications)
        } else {
            restoreNotifications(for: task)
        }
        try save()
    }
    
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
        if task.removed {
            UNUserNotificationCenter.current().removeNotifications(for: task.notifications)
        } else {
            restoreNotifications(for: task)
        }
        try save()
    }
}


extension TaskService {
    static func restoreNotifications(for task: TaskEntity) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeNotifications(for: task.notifications)
        guard let notificationsSet = task.notifications as? Set<NotificationEntity> else { return }
        
        for entity in notificationsSet {
            guard let targetDate = entity.target, targetDate > Date() else { continue }
            
            let identifier = entity.id?.uuidString ?? ""
            let content = UNMutableNotificationContent()
            let type = TaskNotification(rawValue: entity.type ?? String()) ?? TaskNotification.inTime
            content.title = type.notificationName
            content.body = task.name ?? ""
            content.sound = .default
            
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                                 from: targetDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling notification with id \(identifier): \(error.localizedDescription)")
                } else {
                    print("Notification successfully setup for \(String(describing: task.name)) at \(targetDate) with type \(entity.type ?? "notification type error")")
                }
            }
        }
    }
    
    static func restoreNotificationsForAllTasks(completion: ((Bool) -> Void)? = nil) {
        // Create a fetch request for tasks that have at least one notification.
        let request: NSFetchRequest<TaskEntity> = NSFetchRequest(entityName: Texts.CoreData.entity)
        request.predicate = NSPredicate(format: "notifications.@count > 0")
        
        do {
            // Fetch tasks with notifications from Core Data.
            let tasksWithNotifications = try viewContext.fetch(request)
            let group = DispatchGroup()
            let notificationCenter = UNUserNotificationCenter.current()
            
            // Iterate over each task
            for task in tasksWithNotifications {
                if let notificationsSet = task.notifications as? Set<NotificationEntity> {
                    for entity in notificationsSet {
                        // Ensure the target date exists and is in the future
                        guard let targetDate = entity.target, targetDate > Date() else { continue }
                        
                        // Convert the ObjectIdentifier (or similar type) to a String
                        let identifier = entity.id?.uuidString ?? String()
                        
                        // Create the notification content
                        let content = UNMutableNotificationContent()
                        let type = TaskNotification(rawValue: entity.type ?? String()) ?? TaskNotification.inTime
                        content.title = type.notificationName
                        content.body = task.name ?? String()
                        content.sound = .default
                        
                        // Create date components from the target date
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                        
                        // Create the notification request
                        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                        
                        group.enter()
                        notificationCenter.add(request) { error in
                            if let error = error {
                                print("Error scheduling notification with id \(identifier): \(error.localizedDescription)")
                            }
                            group.leave()
                        }
                    }
                }
            }
            
            // Call the completion handler once all notifications are scheduled.
            group.notify(queue: .main) {
                completion?(true)
            }
        } catch {
            print("Error fetching tasks for restoring notifications: \(error.localizedDescription)")
            completion?(false)
        }
    }
}
