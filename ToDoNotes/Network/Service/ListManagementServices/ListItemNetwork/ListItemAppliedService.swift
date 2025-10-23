//
//  ListItemAppliedService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 28/09/2025.
//

import Foundation
import CoreData
import OSLog

private let logger = Logger(subsystem: "com.todonotes.listing", category: "ListItemNetworkService")

extension ListItemNetworkService {
    /// Syncs the checklist items for a backend task with the server.
    internal func syncChecklistIfNeeded(for task: TaskEntity) {
        guard let serverId = task.serverId, !serverId.isEmpty else { return }
        guard let context = task.managedObjectContext else { return }

        // Fetch items (checklist) from server
        self.fetchItems(listId: serverId) { result in
            switch result {
            case .success(let syncResult):
                let remoteItems = syncResult.upserts
                let localChecklist = (task.checklist?.array as? [ChecklistEntity]) ?? []

                // Map checklist by serverId for quick lookup
                var localByServerId: [String: ChecklistEntity] = [:]
                for item in localChecklist {
                    if let serverId = item.serverId {
                        localByServerId[serverId] = item
                    }
                }

                // Upsert remote checklist items
                for remote in remoteItems {
                    if let localItem = localByServerId[remote.id] {
                        // Update fields
                        localItem.name = remote.title
                        localItem.completed = remote.done
                    } else {
                        // Insert new ChecklistEntity if does not exist
                        let newItem = ChecklistEntity(context: context)
                        newItem.id = UUID()
                        newItem.serverId = remote.id
                        newItem.name = remote.title
                        newItem.completed = remote.done
                        // Relationship: add to task
                        var checklist = (task.checklist?.array as? [ChecklistEntity]) ?? []
                        checklist.append(newItem)
                        task.checklist = NSOrderedSet(array: checklist)
                    }
                }

                // Handle deletes (remote deletions)
                let deletedIds = Set(syncResult.deletes.map { $0.id })
                if !deletedIds.isEmpty {
                    let toRemove = localChecklist.filter { item in
                        if let sid = item.serverId { return deletedIds.contains(sid) } else { return false }
                    }
                    for item in toRemove {
                        context.delete(item)
                    }
                }

                // Save context if there were changes
                do {
                    try context.save()
                } catch {
                    logger.error("Failed to save checklist context after sync: \(error.localizedDescription)")
                }
                logger.info("Checklist sync finished for task: \(serverId)")
            case .failure(let error):
                logger.error("Failed to sync checklist from server: \(error.localizedDescription)")
            }
        }
    }

    /// Syncs checklist items for a specific task entity (for TaskManagementView on open).
    internal func syncChecklistForTaskEntity(_ task: TaskEntity) {
        syncChecklistIfNeeded(for: task)
    }

    // MARK: - Checklist Management

    /// Creates a new checklist item on the server and locally.
    internal func createChecklistItem(for task: TaskEntity, with title: String, completion: ((Result<ChecklistEntity, Error>) -> Void)? = nil) {
        guard let listServerId = task.serverId, !listServerId.isEmpty else {
            completion?(.failure(NSError(domain: "Checklist", code: -1, userInfo: [NSLocalizedDescriptionKey: "No serverId for parent task."]))); return
        }
        self.createItem(listId: listServerId, title: title, notes: "", dueAt: nil) { result in
            switch result {
            case .success(let remoteItem):
                guard let context = task.managedObjectContext else { completion?(.failure(NSError(domain: "Checklist", code: -2, userInfo: nil))); return }
                let checklistEntity = ChecklistEntity(context: context)
                checklistEntity.serverId = remoteItem.id
                checklistEntity.name = remoteItem.title
                checklistEntity.completed = remoteItem.done
                // Add to task's checklist
                var checklist = (task.checklist?.array as? [ChecklistEntity]) ?? []
                checklist.append(checklistEntity)
                task.checklist = NSOrderedSet(array: checklist)
                do {
                    try context.save()
                    completion?(.success(checklistEntity))
                } catch {
                    completion?(.failure(error))
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

    /// Updates an existing checklist item on the server and locally.
    internal func updateChecklistItem(_ checklistItem: ChecklistEntity, for task: TaskEntity, completion: ((Result<ChecklistEntity, Error>) -> Void)? = nil) {
        guard let listServerId = task.serverId, !listServerId.isEmpty, let itemServerId = checklistItem.serverId else {
            completion?(.failure(NSError(domain: "Checklist", code: -3, userInfo: [NSLocalizedDescriptionKey: "No server id for task or item."]))); return
        }
        self.updateItem(listId: listServerId, id: itemServerId, title: checklistItem.name, done: checklistItem.completed, notes: nil, dueAt: nil) { result in
            switch result {
            case .success(let remoteItem):
                checklistItem.name = remoteItem.title
                checklistItem.completed = remoteItem.done
                do {
                    try checklistItem.managedObjectContext?.save()
                    completion?(.success(checklistItem))
                } catch {
                    completion?(.failure(error))
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

    /// Deletes a checklist item from the server and locally.
    internal func deleteChecklistItem(_ checklistItem: ChecklistEntity, for task: TaskEntity, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let listServerId = task.serverId, !listServerId.isEmpty, let itemServerId = checklistItem.serverId else {
            completion?(.failure(NSError(domain: "Checklist", code: -4, userInfo: [NSLocalizedDescriptionKey: "No server id for task or item."]))); return
        }
        self.deleteItem(listId: listServerId, id: itemServerId) { result in
            switch result {
            case .success:
                if let context = checklistItem.managedObjectContext {
                    context.delete(checklistItem)
                    do {
                        try context.save()
                        completion?(.success(()))
                    } catch {
                        completion?(.failure(error))
                    }
                } else {
                    completion?(.success(()))
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
