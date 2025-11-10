//
//  ListNetworkAppliedService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 28/09/2025.
//

import Foundation
import CoreData
import OSLog

private let logger = Logger(subsystem: "com.todonotes.listing", category: "ListNetworkService")

extension ListNetworkService {
    
    internal func syncTasksIfNeeded(for task: TaskEntity, since: String?) {
        let context = task.managedObjectContext
        if let serverId = task.serverId, !serverId.isEmpty {
            self.fetchLists(since: since) { result in
                switch result {
                case .success(let syncResult):
                    if let remote = syncResult.upserts.first(where: { $0.id == serverId }) {
                        let serverUpdatedAt = Date.iso8601DateFormatter.date(from: remote.updatedAt)
                        let localUpdatedAt = task.updatedAt ?? Date.distantPast
                        
                        if let serverUpdatedAt = serverUpdatedAt {
                            if serverUpdatedAt > localUpdatedAt {
                                task.name = remote.name
                                task.removed = remote.archived
                                task.updatedAt = serverUpdatedAt
                                logger.info("Local task updated from server: \(serverId)")
                                if let context {
                                    do {
                                        try context.save()
                                    } catch {
                                        logger.error("Failed to save updated local task: \(error.localizedDescription)")
                                    }
                                }
                            } else if localUpdatedAt > serverUpdatedAt {
                                self.updateList(to: task) { updateResult in
                                    switch updateResult {
                                    case .success(let listItem):
                                        logger.info("Task updated on backend from local changes: \(listItem.id)")
                                    case .failure(let error):
                                        logger.error("Failed to update backend task from local changes: \(error.localizedDescription)")
                                    }
                                }
                                logger.info("Server task updated from local task: \(serverId)")
                            } else {
                                logger.info("Task is synchronized and up to date: \(serverId)")
                            }
                        } else {
                            logger.error("Failed to parse server updatedAt date for task id: \(serverId)")
                        }
                    } else {
                        self.createList(for: task) { createResult in
                            switch createResult {
                            case .success(let listItem):
                                logger.info("Task created on backend: \(listItem.id)")
                                task.serverId = listItem.id
                                if let context {
                                    do {
                                        try context.save()
                                    } catch {
                                        logger.error("Failed to save serverId to Core Data: \(error.localizedDescription)")
                                    }
                                }
                            case .failure(let error):
                                logger.error("Failed to create backend task: \(error.localizedDescription)")
                            }
                        }
                    }
                case .failure(let error):
                    logger.error("Failed to fetch server lists before update: \(error.localizedDescription)")
                }
            }
        } else {
            self.createList(for: task) { createResult in
                switch createResult {
                case .success(let listItem):
                    logger.info("Task created on backend: \(listItem.id)")
                    task.serverId = listItem.id
                    if let context {
                        do { try context.save() } catch { logger.error("Failed to save new serverId to Core Data: \(error.localizedDescription)") }
                    }
                case .failure(let error):
                    logger.error("Failed to create backend task: \(error.localizedDescription)")
                }
            }
        }
    }
    
    internal func syncAllBackTasks(since: String?) {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let localTasks = try context.fetch(fetchRequest)
            backendSyncAllTasks(since: since, context: context, localTasks: localTasks)
        } catch {
            logger.error("Failed to fetch backend tasks for sync: \(error.localizedDescription)")
        }
    }
    
    private func backendSyncAllTasks(since: String?, context: NSManagedObjectContext, localTasks: [TaskEntity]) {
        self.fetchLists(since: since) { result in
            switch result {
            case .success(let syncResult):
                let deletedTasks = syncResult.deletes
                self.syncLists(syncResult.upserts, deletedTasks: deletedTasks, localTasks: localTasks, since: since)
            case .failure(let error):
                logger.error("Failed to fetch lists from server for import: \(error.localizedDescription)")
            }
        }
    }
    
    internal func syncLists(_ upsertTasks: [ListItem], deletedTasks: [ListDelete] = [], localTasks: [TaskEntity] = [], since: String? = nil) {
        var localTasks = localTasks
        
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        for deleted in deletedTasks {
            if let taskToDelete = localTasks.first(where: { $0.serverId == deleted.id }) {
                context.delete(taskToDelete)
                if let index = localTasks.firstIndex(where: { $0 === taskToDelete }) {
                    localTasks.remove(at: index)
                }
                logger.info("Deleted local task because it was deleted on server: \(deleted.id)")
            }
        }
        
        context.performAndWait {
            do {
                let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                let localTasks = try context.fetch(fetchRequest)
                
                let localTasksToUpload = localTasks.filter { local in
                    guard let serverId = local.serverId, !serverId.isEmpty else { return true }
                    return !upsertTasks.contains(where: { $0.id == serverId })
                }
                
                for local in localTasksToUpload {
                    let sinceDate = Date.iso8601SecondsDateFormatter.date(from: since ?? "") ?? .distantPast
                    let updatedDate = local.updatedAt ?? .distantPast
                    guard updatedDate > sinceDate else { continue }
                    ListNetworkService.shared.createList(for: local) { createResult in
                        switch createResult {
                        case .success(let listItem):
                            logger.info("Local task uploaded to backend: \(listItem.id)")
                            local.serverId = listItem.id
                            do { try context.save() } catch {
                                logger.error("Failed to save serverId to Core Data: \(error.localizedDescription)")
                            }
                        case .failure(let error):
                            logger.error("Failed to upload local task to backend: \(error.localizedDescription)")
                        }
                    }
                }
                for remote in upsertTasks {
                    if let task = localTasks.first(where: { $0.serverId == remote.id }),
                       let _ = task.serverId {
                        
                        let completed: Int16 = !remote.isTask ? 0 : (remote.done ? 2 : 1)
                        let parsedDate = Date.iso8601DateFormatter.date(from: remote.updatedAt)
                        let localDate = task.updatedAt ?? Date.distantPast
                        
                        let dueAtDate = Date.iso8601SecondsDateFormatter.date(from: remote.dueAt ?? String())
                        
                        if let parsedDate, parsedDate > localDate {
                            task.name = remote.name
                            task.details = remote.details
                            task.completed = completed
                            task.important = remote.important
                            task.pinned = remote.pinned
                            task.target = dueAtDate
                            task.hasTargetTime = remote.hasDueTime
                            task.removed = remote.archived
                            task.updatedAt = parsedDate
                            if let folder = remote.folder {
                                let folderFetch: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
                                folderFetch.predicate = NSPredicate(format: "serverId == %@", folder)
                                folderFetch.fetchLimit = 1
                                if let foundFolder = try? context.fetch(folderFetch).first {
                                    task.folder = foundFolder
                                }
                            }
                            logger.info("Local task updated from server: \(remote.id) \(remote.name)")
                        } else if let parsedDate, localDate > parsedDate {
                            ListNetworkService.shared.updateList(to: task) { updateResult in
                                switch updateResult {
                                case .success(let listItem):
                                    logger.info("Task updated on backend from local changes: \(listItem.id)")
                                case .failure(let error):
                                    logger.error("Failed to update backend task from local changes: \(error.localizedDescription)")
                                }
                            }
                            logger.info("Server task updated from local task: \(remote.id)")
                        }
                    } else {
                        let completed: Int16 = !remote.isTask ? 0 : (remote.done ? 2 : 1)
                        let dueAtDate = Date.iso8601SecondsDateFormatter.date(from: remote.dueAt ?? String())
                        
                        let newTask = TaskEntity(context: context)
                        newTask.id = UUID()
                        newTask.serverId = remote.id
                        newTask.name = remote.name
                        newTask.details = remote.details
                        newTask.completed = completed
                        newTask.important = remote.important
                        newTask.pinned = remote.pinned
                        newTask.target = dueAtDate
                        newTask.hasTargetTime = remote.hasDueTime
                        newTask.removed = remote.archived
                        if let parsedDate = Date.iso8601DateFormatter.date(from: remote.updatedAt) {
                            newTask.updatedAt = parsedDate
                        }
                        if let createdDate = Date.iso8601DateFormatter.date(from: remote.createdAt) {
                            newTask.created = createdDate
                        }
                        if let folder = remote.folder {
                            let folderFetch: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
                            folderFetch.predicate = NSPredicate(format: "serverId == %@", folder)
                            folderFetch.fetchLimit = 1
                            if let foundFolder = try? context.fetch(folderFetch).first {
                                newTask.folder = foundFolder
                            }
                        }
                    }
                }
                
                do {
                    try context.save()
                } catch {
                    logger.error("Failed to save imported tasks: \(error.localizedDescription)")
                }
            } catch {
                logger.error("Failed to save imported tasks: \(error.localizedDescription)")
            }
        }
    }
    
    internal func updateTaskOnServer(for task: TaskEntity, completion: ((Result<ListItem, Error>) -> Void)? = nil) {
        let context = task.managedObjectContext
        guard let serverId = task.serverId, !serverId.isEmpty else {
            logger.error("updateTaskOnServer: serverId is missed")
            self.createList(for: task) { createResult in
                switch createResult {
                case .success(let listItem):
                    logger.info("Task created on backend: \(listItem.id)")
                    task.serverId = listItem.id
                    if let context {
                        do {
                            try context.save()
                            completion?(.success(listItem))
                        } catch {
                            logger.error("Failed to save serverId to Core Data: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    completion?(.failure(error))
                    logger.error("Failed to create backend task: \(error.localizedDescription)")
                }
            }
            return
        }
        self.updateList(to: task) { result in
            switch result {
            case .success(let listItem):
                logger.info("Task updated on backend: \(listItem.id)")
                completion?(.success(listItem))
            case .failure(let error):
                logger.error("Failed to archive task on backend: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }
    
    /// Applies a received ListItem (task) to the local Core Data database.
    /// - Parameter item: The ListItem to apply.
    internal func applyListItem(_ item: ListItem) {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "serverId == %@", item.id)
        fetchRequest.fetchLimit = 1
        let task: TaskEntity
        if let entity = try? context.fetch(fetchRequest).first {
            task = entity
        } else {
            task = TaskEntity(context: context)
            task.id = UUID()
            if let createdDate = Date.iso8601DateFormatter.date(from: item.createdAt) {
                task.created = createdDate
            }
        }
        task.serverId = item.id
        task.name = item.name
        task.details = item.details
        task.completed = item.isTask ? (item.done ? 2 : 1) : 0
        if let dueDate = item.dueAt, let parsedDate = Date.iso8601SecondsDateFormatter.date(from: dueDate) {
            task.target = parsedDate
        } else {
            task.target = nil
        }
        task.hasTargetTime = item.hasDueTime
        task.important = item.important
        task.pinned = item.pinned
        task.removed = item.archived
        if let updatedDate = Date.iso8601DateFormatter.date(from: item.updatedAt) {
            task.updatedAt = updatedDate
        }
        if let folderId = item.folder {
            let folderFetch: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
            folderFetch.predicate = NSPredicate(format: "serverId == %@", folderId)
            folderFetch.fetchLimit = 1
            if let foundFolder = try? context.fetch(folderFetch).first {
                task.folder = foundFolder
            }
        }
        do {
            try context.save()
        } catch {
            logger.error("Failed to save task from ListItem: \(error.localizedDescription)")
        }
    }
}
