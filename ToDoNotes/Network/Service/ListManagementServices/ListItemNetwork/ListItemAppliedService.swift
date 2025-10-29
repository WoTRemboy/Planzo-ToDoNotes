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
    internal func syncChecklistIfNeeded(for task: TaskEntity, completion: (() -> Void)? = nil) {
        guard let serverId = task.serverId, !serverId.isEmpty else { return }
        let context = CoreDataProvider.shared.persistentContainer.viewContext

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
                var checklistToAdd = [ChecklistEntity]()
                for remote in remoteItems {
                    if let localItem = localByServerId[remote.id] {
                        // Update fields
                        localItem.serverId = remote.id
                        localItem.name = remote.title
                        localItem.completed = remote.done
                    } else {
                        // Insert new ChecklistEntity if does not exist
                        let newItem = ChecklistEntity(context: context)
                        newItem.id = UUID()
                        newItem.serverId = remote.id
                        newItem.name = remote.title
                        newItem.completed = remote.done
                        newItem.task = task
                        checklistToAdd.append(newItem)
                    }
                }
                var checklist = (task.checklist?.array as? [ChecklistEntity]) ?? []
                checklist.append(contentsOf: checklistToAdd)
                task.checklist = NSOrderedSet(array: checklist)

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
                completion?()
            case .failure(let error):
                logger.error("Failed to sync checklist from server: \(error.localizedDescription)")
                completion?()
            }
        }
    }

    /// Syncs checklist items for a specific task entity (for TaskManagementView on open).
    internal func syncChecklistForTaskEntity(_ task: TaskEntity, completion: (() -> Void)? = nil) {
        syncChecklistIfNeeded(for: task, completion: completion)
    }

    // MARK: - Checklist Management

    /// Creates a new checklist item on the server and locally.
    internal func createChecklistItem(for task: TaskEntity, item: ChecklistEntity, completion: ((Result<String, Error>) -> Void)? = nil) {
        guard let listServerId = task.serverId, !listServerId.isEmpty else {
            completion?(.failure(NSError(domain: "Checklist", code: -1, userInfo: [NSLocalizedDescriptionKey: "No serverId for parent task."]))); return
        }
        self.createItem(for: item, listId: listServerId) { result in
            switch result {
            case .success(let remoteItem):
                completion?(.success(remoteItem.id))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

    /// Updates an existing checklist item on the server and locally.
    internal func updateChecklistItem(_ checklistItem: ChecklistEntity, for task: TaskEntity, completion: ((Result<String, Error>) -> Void)? = nil) {
        guard let listServerId = task.serverId, !listServerId.isEmpty, let itemServerId = checklistItem.serverId else {
            completion?(.failure(NSError(domain: "Checklist", code: -3, userInfo: [NSLocalizedDescriptionKey: "No server id for task or item."]))); return
        }
        self.updateItem(listId: listServerId, id: itemServerId, title: checklistItem.name, done: checklistItem.completed, notes: nil, dueAt: nil) { result in
            switch result {
            case .success(let remoteItem):
                completion?(.success(remoteItem.id))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

    /// Deletes a checklist item from the server and locally.
    static internal func deleteChecklistItem(_ checklistItem: ChecklistItem, for task: TaskEntity, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let listServerId = task.serverId, !listServerId.isEmpty, let itemServerId = checklistItem.serverId else {
            completion?(.failure(NSError(domain: "Checklist", code: -4, userInfo: [NSLocalizedDescriptionKey: "No server id for task or item."]))); return
        }
        self.deleteItem(listId: listServerId, id: itemServerId) { result in
            switch result {
            case .success:
                completion?(.success(()))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
