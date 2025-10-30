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
    internal func syncChecklistIfNeeded(for task: TaskEntity, since: String?, completion: (() -> Void)? = nil) {
        guard let serverId = task.serverId, !serverId.isEmpty else { return }
        let context = CoreDataProvider.shared.persistentContainer.viewContext

        // Fetch items (checklist) from server
        self.fetchItems(listId: serverId, since: since) { result in
            switch result {
            case .success(let syncResult):
                let localChecklist = ((task.checklist as? Set<ChecklistEntity>) ?? []).sorted { $0.order < $1.order }
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
                
                let remoteItems = syncResult.upserts

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
                        let updatedRemoteDate = Date.iso8601DateFormatter.date(from: remote.updatedAt) ?? .distantPast
                        let updatedLocalDate = (task.updatedAt ?? .distantPast).addingTimeInterval(1)
                        if updatedRemoteDate > updatedLocalDate {
                            // Update fields
                            localItem.serverId = remote.id
                            localItem.name = remote.title
                            localItem.completed = remote.done
                            localItem.order = Int32(remote.order)
                        } else {
                            self.updateChecklistItem(localItem, for: task)
                        }
                    } else {
                        // Insert new ChecklistEntity if does not exist
                        let newItem = ChecklistEntity(context: context)
                        newItem.id = UUID()
                        newItem.serverId = remote.id
                        newItem.name = remote.title
                        newItem.completed = remote.done
                        newItem.task = task
                        newItem.order = Int32(remote.order)
                        checklistToAdd.append(newItem)
                    }
                }
                var checklist = ((task.checklist as? Set<ChecklistEntity>) ?? []).sorted { $0.order < $1.order }
                for newItem in checklistToAdd {
                    let insertIndex = checklist.firstIndex(where: { newItem.order < $0.order }) ?? checklist.count
                    checklist.insert(newItem, at: insertIndex)
                }
                for (index, item) in checklist.enumerated() {
                    item.order = Int32(index)
                }
                task.checklist = NSSet(array: checklist)

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
    internal func syncChecklistForTaskEntity(_ task: TaskEntity, since: String?, completion: (() -> Void)? = nil) {
        syncChecklistIfNeeded(for: task, since: since, completion: completion)
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
        guard let listServerId = task.serverId, !listServerId.isEmpty else {
            completion?(.failure(NSError(domain: "Checklist", code: -3, userInfo: [NSLocalizedDescriptionKey: "No server id for task or item."]))); return
        }
        self.updateItem(listId: listServerId, item: checklistItem) { result in
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

