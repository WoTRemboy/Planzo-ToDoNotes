//
//  ShareCoreDataService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 04/11/2025.
//

import Foundation
import CoreData

final class ShareCoreDataService {
    static let shared = ShareCoreDataService()
    
    private var viewContext: NSManagedObjectContext {
        CoreDataProvider.shared.persistentContainer.viewContext
    }
    
    // MARK: - Create or Update Share
    /// Saves or updates a ShareEntity in Core Data
    @discardableResult
    internal func saveShare(
        id: UUID? = nil,
        serverId: String?,
        scope: String?,
        activeNow: Bool,
        revoked: Bool,
        createdAt: Date?,
        expiresAt: Date?,
        task: TaskEntity?
    ) -> ShareEntity {
        let entity: ShareEntity
        if let id = id {
            entity = fetchShareEntity(by: id) ?? ShareEntity(context: viewContext)
            entity.id = id
        } else {
            entity = ShareEntity(context: viewContext)
            entity.id = UUID()
        }
        entity.serverId = serverId
        entity.scope = scope
        entity.activeNow = activeNow
        entity.revoked = revoked
        entity.createdAt = createdAt
        entity.expiresAt = expiresAt
        entity.task = task
        saveContext()
        return entity
    }
    
    // MARK: - Fetch Shares
    /// Fetches all ShareEntity objects
    internal func fetchAllShares() -> [ShareEntity] {
        let request: NSFetchRequest<ShareEntity> = ShareEntity.fetchRequest()
        if let entities = try? viewContext.fetch(request) {
            return entities
        }
        return []
    }
    
    /// Fetches ShareEntities by serverId
    internal func fetchShareEntities(byServerId serverId: String) -> [ShareEntity] {
        let request: NSFetchRequest<ShareEntity> = ShareEntity.fetchRequest()
        request.predicate = NSPredicate(format: "serverId == %@", serverId)
        return (try? viewContext.fetch(request)) ?? []
    }

    /// Fetches ShareEntity by UUID
    internal func fetchShareEntity(by id: UUID) -> ShareEntity? {
        let request: NSFetchRequest<ShareEntity> = ShareEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? viewContext.fetch(request).first
    }

    /// Fetches ShareEntities for a TaskEntity
    internal func fetchShareEntities(for task: TaskEntity) -> [ShareEntity] {
        let request: NSFetchRequest<ShareEntity> = ShareEntity.fetchRequest()
        request.predicate = NSPredicate(format: "task == %@", task)
        return (try? viewContext.fetch(request)) ?? []
    }
    
    // MARK: - Delete Share
    /// Deletes a ShareEntity by UUID
    internal func deleteShare(by id: UUID) {
        guard let entity = fetchShareEntity(by: id) else { return }
        viewContext.delete(entity)
        saveContext()
    }
    
    /// Deletes a ShareEntity object directly
    internal func deleteShare(_ share: ShareEntity) {
        viewContext.delete(share)
        saveContext()
    }
    
    // MARK: - Helpers
    private func saveContext() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
}

