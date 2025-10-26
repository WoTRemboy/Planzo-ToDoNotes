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
    
    internal func syncTasksIfNeeded(for task: TaskEntity) {
        let name = task.name ?? String()
        let context = task.managedObjectContext
        if let serverId = task.serverId, !serverId.isEmpty {
            self.fetchLists { result in
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
                                self.updateList(id: serverId, name: name, archived: task.removed) { updateResult in
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
                        self.createList(name: name) { createResult in
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
            self.createList(name: name) { createResult in
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
    
    internal func syncAllBackTasks() {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "folder == %@", FolderEnum.back.rawValue)
        do {
            let localTasks = try context.fetch(fetchRequest)
            backendSyncAllTasks(context: context, localTasks: localTasks)
        } catch {
            logger.error("Failed to fetch backend tasks for sync: \(error.localizedDescription)")
        }
    }
    
    private func backendSyncAllTasks(context: NSManagedObjectContext, localTasks: [TaskEntity]) {
        self.fetchLists { result in
            switch result {
            case .success(let syncResult):
                let remoteTasks = syncResult.upserts
                
                for remote in remoteTasks {
                    if let task = localTasks.first(where: { $0.serverId == remote.id }),
                       let serverId = task.serverId {
                        
                        let parsedDate = Date.iso8601DateFormatter.date(from: remote.updatedAt)
                        let localDate = task.updatedAt ?? Date.distantPast
                        
                        if let parsedDate, parsedDate > localDate {
                            task.name = remote.name
                            task.removed = remote.archived
                            task.updatedAt = parsedDate
                            logger.info("Local task updated from server: \(remote.id)")
                        } else if let parsedDate, localDate > parsedDate {
                            self.updateList(id: serverId, name: task.name, archived: task.removed) { updateResult in
                                switch updateResult {
                                case .success(let listItem):
                                    logger.info("Task updated on backend from local changes: \(listItem.id)")
                                case .failure(let error):
                                    logger.error("Failed to update backend task from local changes: \(error.localizedDescription)")
                                }
                            }
                            logger.info("Server task updated from local task: \(remote.id)")
                        } else {
                            logger.info("Task is synchronized and up to date: \(remote.id)")
                        }
                    } else {
                        let newTask = TaskEntity(context: context)
                        newTask.id = UUID()
                        newTask.serverId = remote.id
                        newTask.name = remote.name
                        newTask.removed = remote.archived
                        if let parsedDate = Date.iso8601DateFormatter.date(from: remote.updatedAt) {
                            newTask.updatedAt = parsedDate
                            newTask.created = parsedDate
                        }
//                        newTask.folder?.name = FolderEnum.back.rawValue
                        logger.info("Local task created from server: \(remote.id)")
                    }
                }
                
                do {
                    try context.save()
                } catch {
                    logger.error("Failed to save imported tasks: \(error.localizedDescription)")
                }
            case .failure(let error):
                logger.error("Failed to fetch lists from server for import: \(error.localizedDescription)")
            }
        }
    }
    
    internal func archiveTaskOnServer(for task: TaskEntity, value: Bool, completion: ((Result<ListItem, Error>) -> Void)? = nil) {
        guard let serverId = task.serverId, !serverId.isEmpty else {
            logger.error("archiveTaskOnServer: serverId is missed")
            completion?(.failure(NSError(domain: "ListNetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "serverId is missed"])))
            return
        }
        self.updateList(id: serverId, archived: value) { result in
            switch result {
            case .success(let listItem):
                logger.info("Task archived on backend: \(listItem.id)")
                completion?(.success(listItem))
            case .failure(let error):
                logger.error("Failed to archive task on backend: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }
}

