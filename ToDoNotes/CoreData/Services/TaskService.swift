//
//  TaskService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import Foundation
import CoreData
import UserNotifications
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.coredata", category: "TaskService")

/// A service that handles all task-related operations such as creation, deletion,
/// status toggling, duplication, and notification scheduling.
final class TaskService {
    
    // MARK: - Private Core Data Context and Save
    
    /// The main view context from Core Data.
    static private var viewContext: NSManagedObjectContext {
        CoreDataProvider.shared.persistentContainer.viewContext
    }
    
    /// Saves the context if changes are pending.
    static private func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
    
    // MARK: - Task Creation / Update
    
    /// Creates or updates a task with the provided attributes.
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
        task.updatedAt = .now
        
        task.important = importance
        task.pinned = pinned
        task.removed = removed
        
        // Converts NotificationItems to Core Data entities
        let notificationEntities = notifications.map { item -> NotificationEntity in
            let entityItem = NotificationEntity(context: viewContext)
            entityItem.id = item.id
            entityItem.type = item.type.rawValue
            entityItem.target = item.target
            return entityItem
        }
        task.notifications = NSSet(array: notificationEntities)
        
        // Converts ChecklistItems to Core Data entities
        let checklistEntities = checklist.map { item -> ChecklistEntity in
            let entityItem = ChecklistEntity(context: viewContext)
            entityItem.name = item.name
            entityItem.completed = item.completed
            return entityItem
        }
        task.checklist = NSOrderedSet(array: checklistEntities)
        
        // Determines folder if not set
        if entity == nil, let folder = folder, !folder.system {
            // Fetch FolderEntity by id
            let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", folder.id as CVarArg)
            fetchRequest.fetchLimit = 1
            if let folderEntity = try? viewContext.fetch(fetchRequest).first {
                task.folder = folderEntity
            }
        }
        
        try save()
        
        // If the task is a backend task and has a serverId, sync checklist items to server
//        if task.folder == FolderEnum.back.rawValue, task.serverId != nil {
//            // For each checklist item, create or update it on the server
//            if let checklistEntities = task.checklist?.array as? [ChecklistEntity] {
//                for checklistEntity in checklistEntities {
//                    if checklistEntity.serverId != nil {
//                        // Update existing checklist item on server
//                        ListItemNetworkService.shared.updateChecklistItem(checklistEntity, for: task)
//                    } else {
//                        // Create new checklist item on server
//                        ListItemNetworkService.shared.createChecklistItem(for: task, with: checklistEntity.name ?? String())
//                    }
//                }
//            }
//        }
        ListNetworkService.shared.updateTaskOnServer(for: task)
    }
    
    // MARK: - Task Duplication
    
    /// Duplicates a given task and its related data.
    static func duplicate(task: TaskEntity?) throws {
        guard let task else { return }
        
        let newTask = TaskEntity(context: viewContext)
        newTask.id = UUID()
        newTask.created = task.created
        newTask.updatedAt = .now
        
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
                newNotification.id = UUID() // Generate new UUID for each notification
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
        
        // Only restore notifications if the task is not completed
        if newTask.completed != 2 {
            restoreNotifications(for: newTask)
        }
        
        ListNetworkService.shared.updateTaskOnServer(for: newTask)
    }
    
    // MARK: - Deletion
    
    /// Permanently deletes a specific task.
    static func deleteRemovedTask(for entity: TaskEntity) throws {
        viewContext.delete(entity)
        try save()
    }
    
    /// Deletes all tasks marked as removed using a batch delete.
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
            logger.debug("Removed tasks deleted successfully.")
        } catch {
            logger.error("Error deleting removed tasks: \(error.localizedDescription)")
        }
    }
    
    /// Deletes all tasks and clears all notifications.
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
            logger.debug("All tasks deleted successfully.")
            completion?(true)
        } catch {
            logger.error("Batch delete error: \(error.localizedDescription)")
            completion?(false)
        }
    }
    
    static func deleteAllBackendTasks() {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let backendTasks = try viewContext.fetch(fetchRequest)
            for task in backendTasks {
                viewContext.delete(task)
            }
            try save()
            logger.debug("All backend tasks deleted successfully.")
        } catch {
            logger.error("Error deleting backend tasks: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Requests
    
    /// Returns a fetch request for all notifications associated with a given task.
    static func getNotificationsByTask(task: TaskEntity) -> NSFetchRequest<NotificationEntity> {
        let request = NotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "task == %@", task)
        return request
    }
    
    /// Returns a fetch request for tasks matching a given search term.
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
        let wasCompleted = task.completed == 2
        task.completed = task.completed == 1 ? 2 : 1
        task.updatedAt = .now
        
        // Only handle notifications if the completion status actually changed
        if task.completed == 2 && !wasCompleted {
            UNUserNotificationCenter.current().removeNotifications(for: task.notifications)
        } else if task.completed != 2 && wasCompleted {
            restoreNotifications(for: task)
        }
        
        try save()
        ListNetworkService.shared.updateTaskOnServer(for: task)
    }
    
    static func toggleImportant(for task: TaskEntity) throws {
        task.important.toggle()
        task.updatedAt = .now
        try save()
        ListNetworkService.shared.updateTaskOnServer(for: task)
    }
    
    static func togglePinned(for task: TaskEntity) throws {
        task.pinned.toggle()
        task.updatedAt = .now
        try save()
        ListNetworkService.shared.updateTaskOnServer(for: task)
    }
    
    static func toggleRemoved(for task: TaskEntity) throws {
        let wasRemoved = task.removed
        task.removed.toggle()
        task.updatedAt = .now
        
        // Only handle notifications if the removed status actually changed
        if task.removed && !wasRemoved {
            UNUserNotificationCenter.current().removeNotifications(for: task.notifications)
        } else if !task.removed && wasRemoved {
            restoreNotifications(for: task)
        }
        try save()
        ListNetworkService.shared.updateTaskOnServer(for: task)
    }
    
    static func updateFolder(for task: TaskEntity, to folder: Folder) throws {
        guard task.folder?.id != folder.id else {
            logger.debug("Folders are the same, no need to update.")
            throw TaskServiceError.folderIsTheSame
        }
        
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", folder.id as CVarArg)
        fetchRequest.fetchLimit = 1
        let folderEntity = try context.fetch(fetchRequest).first
        if folderEntity == nil {
            logger.error("No FolderEntity with id: \(folder.id.uuidString) found.")
            throw TaskServiceError.folderIsTheSame
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            task.folder = folderEntity
            task.updatedAt = .now
            do {
                try save()
                logger.debug("Folder updated and context saved successfully.")
                ListNetworkService.shared.updateTaskOnServer(for: task)
            } catch {
                logger.error("Error saving context after updating folder: \(error.localizedDescription)")
            }
        }
    }
}


extension TaskService {
    static func restoreNotifications(for task: TaskEntity) {
        // First remove any existing notifications for this task
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeNotifications(for: task.notifications)
        
        // Skip if task is completed or removed
        guard task.completed != 2 && !task.removed else { return }
        
        guard let notificationsSet = task.notifications as? Set<NotificationEntity> else { return }
        
        // Get current pending notifications to check for duplicates
        notificationCenter.getPendingNotificationRequests { pendingRequests in
            let existingIdentifiers = Set(pendingRequests.map { $0.identifier })
            
            for entity in notificationsSet {
                guard let targetDate = entity.target,
                      targetDate > Date() else { continue }
                
                let identifier = entity.id?.uuidString ?? ""
                
                // Skip if notification with this ID already exists
                guard !existingIdentifiers.contains(identifier) else {
                    logger.warning("Skipping duplicate notification with ID: \(identifier)")
                    continue
                }
                
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
                        logger.error("Error scheduling notification with id \(identifier): \(error.localizedDescription)")
                    } else {
                        logger.debug("Notification successfully setup for \(String(describing: task.name)) at \(targetDate) with type \(entity.type ?? "notification type error").")
                    }
                }
            }
        }
    }
    
    static func restoreNotificationsForAllTasks(completion: ((Bool) -> Void)? = nil) {
        let request: NSFetchRequest<TaskEntity> = NSFetchRequest(entityName: Texts.CoreData.entity)
        request.predicate = NSPredicate(format: "notifications.@count > 0 AND completed != 2 AND removed == NO")
        
        do {
            let tasksWithNotifications = try viewContext.fetch(request)
            let group = DispatchGroup()
            let notificationCenter = UNUserNotificationCenter.current()
            
            // First remove all existing notifications
            notificationCenter.removeAllPendingNotificationRequests()
            
            // Get current pending notifications to check for duplicates
            notificationCenter.getPendingNotificationRequests { pendingRequests in
                let existingIdentifiers = Set(pendingRequests.map { $0.identifier })
                
                for task in tasksWithNotifications {
                    if let notificationsSet = task.notifications as? Set<NotificationEntity> {
                        for entity in notificationsSet {
                            guard let targetDate = entity.target,
                                  targetDate > Date() else { continue }
                            
                            let identifier = entity.id?.uuidString ?? ""
                            
                            // Skip if notification with this ID already exists
                            guard !existingIdentifiers.contains(identifier) else {
                                logger.warning("Skipping duplicate notification with ID: \(identifier)")
                                continue
                            }
                            
                            let content = UNMutableNotificationContent()
                            let type = TaskNotification(rawValue: entity.type ?? String()) ?? TaskNotification.inTime
                            content.title = type.notificationName
                            content.body = task.name ?? String()
                            content.sound = .default
                            
                            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                            
                            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                            
                            group.enter()
                            notificationCenter.add(request) { error in
                                if let error = error {
                                    logger.error("Error scheduling notification with id \(identifier): \(error.localizedDescription).")
                                } else {
                                    logger.debug("Notification successfully setup for \(String(describing: task.name)) at \(targetDate) with type \(entity.type ?? "notification type error").")
                                }
                                group.leave()
                            }
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    logger.debug("Notifications successfully restored for all tasks.")
                    completion?(true)
                }
            }
        } catch {
            logger.error("Error fetching tasks for restoring notifications: \(error.localizedDescription).")
            completion?(false)
        }
    }
}

enum TaskServiceError: Error {
    case folderIsTheSame
}

