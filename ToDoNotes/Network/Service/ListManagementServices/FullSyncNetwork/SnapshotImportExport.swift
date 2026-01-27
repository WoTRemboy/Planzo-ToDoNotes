//
//  SnapshotImportExport.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/01/2026.
//

import Foundation
import OSLog
import CoreData

private let logger = Logger(subsystem: "com.todonotes.importexport", category: "SnapshotImportExport")

extension FullSyncNetworkService {
    
    /// Exports all local Lists (without shareLinks) and Items into a JSON file in the app's Documents directory.
    /// The JSON structure mirrors server snapshot response fields; folders/notifications/shares are exported as empty arrays.
    /// - Parameter completion: Completion with file URL or error.
    func exportLocalSnapshot(completion: @escaping (Result<URL, Error>) -> Void) {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.sortDescriptors = []
        
        context.perform {
            do {
                let tasks = try context.fetch(request)
                // Map TaskEntity -> ListItem (shareLinks excluded)
                let lists: [ListItem] = tasks.map { self.mapTaskEntityToListItem($0) }
                // Map ChecklistEntity -> ListTaskItem
                var items: [ListTaskItem] = []
                for task in tasks {
                    if let serverId = task.serverId, !serverId.isEmpty,
                       let checklist = task.checklist as? Set<ChecklistEntity> {
                        let mapped = checklist.sorted { $0.order < $1.order }.map { self.mapChecklistEntityToListTaskItem($0, listId: serverId, parentUpdatedAt: task.updatedAt) }
                        items.append(contentsOf: mapped)
                    }
                }
                
                let snapshot = FullSyncSnapshotResponse(
                    now: Date.iso8601DateFormatter.string(from: .now),
                    nextCursor: nil,
                    folders: [],
                    lists: lists,
                    items: items,
                    notifications: [],
                    shares: []
                )
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(snapshot)
                
                let fileName = "ToDoNotesExport-\(Int(Date().timeIntervalSince1970)).json"
                let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documents.appendingPathComponent(fileName)
                try data.write(to: fileURL, options: .atomic)
                logger.info("Local snapshot exported to: \(fileURL.path)")
                DispatchQueue.main.async { completion(.success(fileURL)) }
            } catch {
                logger.error("Failed to export local snapshot: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
    
    /// Imports a previously exported JSON snapshot file and applies its Lists and Items to the local store.
    /// - Parameters:
    ///   - url: File URL to JSON snapshot.
    ///   - completion: Completion with success or error.
    func importLocalSnapshot(from url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(FullSyncSnapshotResponse.self, from: data)
                logger.info("Local snapshot imported. Lists: \(decoded.lists.count), Items: \(decoded.items.count)")
                // Apply using new helper
                self.applySnapshot(decoded)
                DispatchQueue.main.async { completion(.success(())) }
            } catch {
                logger.error("Failed to import local snapshot: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
    
    // MARK: - Mapping helpers
    
    private func mapTaskEntityToListItem(_ task: TaskEntity) -> ListItem {
        let id = task.serverId ?? UUID().uuidString
        let ownerSub = "local"
        let name = task.name ?? ""
        let archived = task.removed
        let createdAt = (task.created ?? Date.distantPast)
        let updatedAt = (task.updatedAt ?? task.created ?? Date())
        let details = task.details
        let folderId = task.folder?.serverId
        let isTask = task.completed != 0
        let done = isTask ? (task.completed == 2) : false
        let important = task.important
        let pinned = task.pinned
        let dueAt: String? = {
            if let target = task.target { return Date.iso8601SecondsDateFormatter.string(from: target) }
            return nil
        }()
        let hasDueTime = task.hasTargetTime
        
        return ListItem(
            id: id,
            ownerSub: ownerSub,
            name: name,
            archived: archived,
            createdAt: Date.iso8601DateFormatter.string(from: createdAt),
            updatedAt: Date.iso8601DateFormatter.string(from: updatedAt),
            shareLinks: [], // explicitly excluded
            details: details,
            folder: folderId,
            done: done,
            isTask: isTask,
            important: important,
            pinned: pinned,
            dueAt: dueAt,
            hasDueTime: hasDueTime
        )
    }
    
    private func mapChecklistEntityToListTaskItem(_ item: ChecklistEntity, listId: String, parentUpdatedAt: Date?) -> ListTaskItem {
        let id = item.id?.uuidString ?? UUID().uuidString
        let title = item.name
        let done = item.completed
        let notes: String? = nil
        let dueAt: String? = nil
        let order = Int(item.order)
        let updatedAt = Date.iso8601DateFormatter.string(from: parentUpdatedAt ?? Date())
        let updatedBy = "local"
        let deleted = false
        let deletedAt: String? = nil
        
        return ListTaskItem(
            id: id,
            listId: listId,
            title: title,
            done: done,
            notes: notes,
            dueAt: dueAt,
            order: order,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            deleted: deleted,
            deletedAt: deletedAt
        )
    }
    
    /// Applies a full snapshot import by recreating all lists and items locally (no serverId linkage).
    /// This method removes existing tasks and recreates them from the provided snapshot.
    private func applySnapshot(_ snapshot: FullSyncSnapshotResponse) {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        context.performAndWait {
            var taskByFileListId: [String: TaskEntity] = [:]
            for list in snapshot.lists {
                let task = TaskEntity(context: context)
                task.id = UUID()
                task.serverId = nil
                task.name = list.name
                task.details = list.details
                task.completed = list.isTask ? (list.done ? 2 : 1) : 0
                task.important = list.important
                task.pinned = list.pinned
                if let due = list.dueAt, let date = Date.iso8601SecondsDateFormatter.date(from: due) {
                    task.target = date
                } else {
                    task.target = nil
                }
                task.hasTargetTime = list.hasDueTime
                task.removed = list.archived
                if let created = Date.iso8601DateFormatter.date(from: list.createdAt) {
                    task.created = created
                }
                if let updated = Date.iso8601DateFormatter.date(from: list.updatedAt) {
                    task.updatedAt = updated
                }
                // Do not set serverId on import
                // Folder mapping by serverId if exists locally
                if let folderId = list.folder {
                    let fReq: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
                    fReq.predicate = NSPredicate(format: "serverId == %@", folderId)
                    fReq.fetchLimit = 1
                    if let folderEntity = try? context.fetch(fReq).first {
                        task.folder = folderEntity
                    }
                }
                taskByFileListId[list.id] = task
            }
            
            // 3) Create checklist items grouped by listId
            let groupedItems = Dictionary(grouping: snapshot.items, by: { $0.listId })
            for (fileListId, items) in groupedItems {
                guard let task = taskByFileListId[fileListId] else { continue }
                let sorted = items.sorted { $0.order < $1.order }
                var entities: [ChecklistEntity] = []
                for item in sorted {
                    let entity = ChecklistEntity(context: context)
                    entity.serverId = nil
                    entity.name = item.title ?? ""
                    entity.completed = item.done
                    entity.order = Int32(item.order)
                    entities.append(entity)
                }
                task.checklist = NSSet(array: entities)
            }
            
            do {
                try context.save()
                logger.info("Snapshot import applied successfully. Lists: \(snapshot.lists.count), Items: \(snapshot.items.count)")
            } catch {
                logger.error("Failed to save context after snapshot import: \(error.localizedDescription)")
            }
        }
    }
}
