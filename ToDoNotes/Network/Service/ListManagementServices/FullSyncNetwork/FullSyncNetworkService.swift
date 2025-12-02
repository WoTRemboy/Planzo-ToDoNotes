//
//  FullSyncNetworkService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 06/11/2025.
//

import Foundation
import OSLog
import CoreData

private let logger = Logger(subsystem: "com.todonotes.sync", category: "FullSyncNetworkService")

struct FullSyncDeltaResponse: Codable {
    let since: String
    let now: String
    let nextCursor: String?
    let folders: FoldersDelta
    let lists: ListsDelta
    let items: ItemsDelta
    let notifications: NotificationsDelta
    let shares: SharesDelta
}

struct FullSyncSnapshotResponse: Codable {
    let now: String
    let nextCursor: String?
    let folders: [FolderUpsert]
    let lists: [ListItem]
    let items: [ListTaskItem]
    let notifications: [NotificationUpsert]
    let shares: [ShareLinkRequest]
}

final class FullSyncNetworkService: ObservableObject {
    // Track last sync status
    @Published private(set) var lastSyncStatus: SyncStatus = .updated
    
    static let shared = FullSyncNetworkService()
    
    // Update sync status
    private func setSyncStatus(to value: SyncStatus) {
        if Thread.isMainThread {
            self.lastSyncStatus = value
        } else {
            DispatchQueue.main.async {
                self.lastSyncStatus = value
            }
        }
    }
    
    func syncAllData(completion: @escaping (Result<Void, Error>) -> Void) {
        // Prevent concurrent sync requests
        guard lastSyncStatus != .updating else {
            logger.warning("Sync already in progress. Skipping new request.")
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "FullSyncNetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sync already in progress"])))
            }
            return
        }
        
        // Track last sync status
        self.setSyncStatus(to: .updating)
        
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/sync/snapshot") else {
                    logger.error("Invalid URL for full sync.")
                    self.setSyncStatus(to: .failed)
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Full sync request failed: \(error.localizedDescription)")
                        self.setSyncStatus(to: .failed)
                        DispatchQueue.main.async { completion(.failure(error)) }
                        return
                    }
                    guard let data = data else {
                        logger.error("Full sync response data is nil.")
                        self.setSyncStatus(to: .failed)
                        DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(FullSyncSnapshotResponse.self, from: data)
                        logger.info("Full sync succeeded. Folders: \(decoded.folders.count), Lists: \(decoded.lists.count), Items: \(decoded.items.count), Notifications: \(decoded.notifications.count), Shares: \(decoded.shares.count)")
                        self.syncLists(decoded.lists)
                        self.syncItems(decoded.items)
                        self.syncShares(decoded.shares)
                        self.syncNotifications(decoded.notifications)
                        self.refreshSharingInfoForAllSharedTasks()
                        DispatchQueue.main.async {
                            UserCoreDataService.shared.updateLastSyncAt()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.setSyncStatus(to: .updated)
                            }
                            completion(.success(()))
                        }
                    } catch {
                        logger.error("Failed to decode full sync response: \(error.localizedDescription)")
                        self.setSyncStatus(to: .failed)
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }
                task.resume()
            case .failure(let error):
                self.setSyncStatus(to: .failed)
                completion(.failure(error))
            }
        }
    }
    
    func syncDeltaData(since: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        // Prevent concurrent sync requests
        guard lastSyncStatus != .updating else {
            logger.warning("Sync already in progress. Skipping new request.")
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "FullSyncNetworkService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sync already in progress"])))
            }
            return
        }
        
        // Track last sync status
        self.setSyncStatus(to: .updating)
        
        let formatter = ISO8601DateFormatter()
        let since: String = since ?? formatter.string(from: .distantPast)
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/sync/delta?since=\(since)") else {
                    logger.error("Invalid URL for delta sync.")
                    self.setSyncStatus(to: .failed)
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Delta sync request failed: \(error.localizedDescription)")
                        self.setSyncStatus(to: .failed)
                        DispatchQueue.main.async { completion(.failure(error)) }
                        return
                    }
                    guard let data = data else {
                        logger.error("Delta sync response data is nil.")
                        self.setSyncStatus(to: .failed)
                        DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(FullSyncDeltaResponse.self, from: data)
                        logger.info("Delta sync succeeded. Folders: \(decoded.folders.upserts.count)/\(decoded.folders.deletes.count), Lists: \(decoded.lists.upserts.count)/\(decoded.lists.deletes.count), Items: \(decoded.items.upserts.count)/\(decoded.items.deletes.count), Notifications: \(decoded.notifications.upserts.count)/\(decoded.notifications.deletes.count), Shares: \(decoded.shares.upserts.count)/\(decoded.shares.deletes.count)")
                        self.syncLists(decoded.lists.upserts, deletes: decoded.lists.deletes, since: since)
                        self.syncItems(decoded.items.upserts, deletedItems: decoded.items.deletes, since: since)
                        self.syncShares(decoded.shares.upserts)
                        self.syncNotifications(decoded.notifications.upserts, deletes: decoded.notifications.deletes, since: since)
                        self.refreshSharingInfoForAllSharedTasks()
                        DispatchQueue.main.async {
                            UserCoreDataService.shared.updateLastSyncAt()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.setSyncStatus(to: .updated)
                            }
                            completion(.success(()))
                        }
                    } catch {
                        logger.error("Failed to decode delta sync response: \(error.localizedDescription)")
                        self.setSyncStatus(to: .failed)
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }
                task.resume()
            case .failure(let error):
                self.setSyncStatus(to: .failed)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Helper stubs for saving entities to Core Data
    
    private func syncItems(_ items: [ListTaskItem], deletedItems: [ItemDelete] = [], since: String? = nil) {
        guard !items.isEmpty else { return }
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let grouped = Dictionary(grouping: items, by: { $0.listId })
        context.performAndWait {
            for (listId, itemsGroup) in grouped {
                let fetch: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                fetch.predicate = NSPredicate(format: "serverId == %@", listId)
                fetch.fetchLimit = 1
                if let task = try? context.fetch(fetch).first {
                    ListItemNetworkService.shared.syncItems(for: task, remoteItems: itemsGroup, since: since)
                } else {
                    logger.error("No TaskEntity found for listId: \(listId)")
                }
            }
        }
    }
    private func syncShares(_ shares: [ShareLinkRequest]) {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let grouped = Dictionary(grouping: shares, by: { $0.listId })
        var roleFetchTargets: [(listId: String, objectID: NSManagedObjectID)] = []
        var membersFetchTargets: [(listId: String, objectID: NSManagedObjectID)] = []
        context.performAndWait {
            for (listId, group) in grouped {
                let fetch: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                fetch.predicate = NSPredicate(format: "serverId == %@", listId)
                fetch.fetchLimit = 1
                if let task = try? context.fetch(fetch).first {
                    // Map ShareLinkRequest to ShareLink
                    let shareLinks: [ShareLink] = group.map { request in
                        ShareLink(
                            id: request.id,
                            createdAt: request.createdAt,
                            expiresAt: request.expiresAt,
                            revoked: request.revoked,
                            scope: request.scope,
                            grantRole: request.grantRole,
                            oneTime: request.oneTime,
                            maxUses: request.maxUses,
                            useCount: request.useCount,
                            usedAt: String(),
                            activeNow: true
                        )
                    }
                    ShareNetworkService.shared.syncShares(for: task, serverShares: shareLinks)
                    if !shareLinks.isEmpty {
                        roleFetchTargets.append((listId: listId, objectID: task.objectID))
                        membersFetchTargets.append((listId: listId, objectID: task.objectID))
                    }
                } else {
                    logger.error("No TaskEntity found for listId: \(listId)")
                }
            }
        }
        for target in roleFetchTargets {
            ShareAccessService.shared.getMyRole(for: target.listId) { result in
                switch result {
                case .success(let role):
                    let context = CoreDataProvider.shared.persistentContainer.viewContext
                    context.perform {
                        do {
                            if let task = try? context.existingObject(with: target.objectID) as? TaskEntity {
                                task.role = role
                                do { try context.save() } catch {
                                    logger.error("Failed to save role to TaskEntity after role fetch: \(error.localizedDescription)")
                                }
                                logger.info("Updated TaskEntity role after role fetch for listId \(target.listId): \(role)")
                            }
                        }
                    }
                case .failure(let error):
                    logger.error("Failed to fetch role for listId \(target.listId): \(error.localizedDescription)")
                }
            }
        }
    }

    private func syncLists(_ upserts: [ListItem], deletes: [ListDelete] = [], since: String? = nil) {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let localTasks: [TaskEntity] = (try? context.fetch(fetchRequest)) ?? []
        
        ListNetworkService.shared.syncLists(upserts, deletedTasks: deletes, localTasks: localTasks, since: since)
    }
    
    private func syncNotifications(_ upserts: [NotificationUpsert], deletes: [NotificationDelete] = [], since: String? = nil) {
        guard !upserts.isEmpty || !deletes.isEmpty else { return }
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        // Group notifications by listId
        let grouped = Dictionary(grouping: upserts, by: { $0.listId })
        context.performAndWait {
            for (listId, notificationsGroup) in grouped {
                let fetch: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                fetch.predicate = NSPredicate(format: "serverId == %@", listId)
                fetch.fetchLimit = 1
                if let task = try? context.fetch(fetch).first {
                    NotificationNetworkService.shared.syncNotifications(for: task, remoteItems: notificationsGroup, deletedItems: deletes, since: since)
                } else {
                    logger.error("No TaskEntity found for listId: \(listId)")
                }
            }
        }
    }
    
    private func refreshSharingInfoForAllSharedTasks() {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "serverId != nil AND serverId != '' AND share.@count > 0")
        var targets: [(listId: String, objectID: NSManagedObjectID, isOwner: Bool)] = []
        context.performAndWait {
            let tasks: [TaskEntity] = (try? context.fetch(fetchRequest)) ?? []
            for task in tasks {
                if let listId = task.serverId, !listId.isEmpty {
                    let isOwner = (task.role == ShareAccess.owner.rawValue)
                    targets.append((listId: listId, objectID: task.objectID, isOwner: isOwner))
                }
            }
        }
        guard !targets.isEmpty else { return }
        for target in targets {
            // Refresh members count only for owners
            if target.isOwner {
                ShareAccessService.shared.getMembers(for: target.listId) { result in
                    switch result {
                    case .success(let members):
                        let context = CoreDataProvider.shared.persistentContainer.viewContext
                        context.perform {
                            if let task = try? context.existingObject(with: target.objectID) as? TaskEntity {
                                task.members = Int16(members.count)
                                do { try context.save() } catch {
                                    logger.error("Failed to save refreshed members count for listId \(target.listId): \(error.localizedDescription)")
                                }
                            }
                        }
                    case .failure(let error):
                        logger.error("Failed to refresh members for listId \(target.listId): \(error.localizedDescription)")
                    }
                }
            }
            // Refresh my role
            ShareAccessService.shared.getMyRole(for: target.listId) { result in
                switch result {
                case .success(let role):
                    let context = CoreDataProvider.shared.persistentContainer.viewContext
                    context.perform {
                        if let task = try? context.existingObject(with: target.objectID) as? TaskEntity {
                            task.role = role
                            do { try context.save() } catch {
                                logger.error("Failed to save refreshed role for listId \(target.listId): \(error.localizedDescription)")
                            }
                        }
                    }
                case .failure(let error):
                    logger.error("Failed to refresh role for listId \(target.listId): \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    internal func refreshTasks(since: String?) async {
        await withCheckedContinuation { continuation in
            self.syncDeltaData(since: since) { result in
                switch result {
                case .success(_):
                    logger.info("Delta data sync successful since: \(since ?? "nil")")
                case .failure(let error):
                    logger.error("Delta data sync failed with error: \(error)")
                }
                continuation.resume()
            }
        }
    }
}

