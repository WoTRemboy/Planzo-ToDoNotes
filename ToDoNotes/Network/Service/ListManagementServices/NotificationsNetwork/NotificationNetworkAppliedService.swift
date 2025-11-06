//
//  NotificationNetworkAppliedService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 31/10/2025.
//

import Foundation
import CoreData
import OSLog

private let logger = Logger(subsystem: "com.todonotes.notifications", category: "NotificationNetworkAppliedService")

extension NotificationNetworkService {
    /// Syncs the notifications for a backend task (list) with the server.
    internal func syncNotificationsIfNeeded(for task: TaskEntity, since: String?, completion: (() -> Void)? = nil) {
        guard let listServerId = task.serverId, !listServerId.isEmpty else { completion?(); return }
        self.fetchNotifications(listId: listServerId, since: since) { result in
            switch result {
            case .success(let syncResult):
                self.syncNotifications(for: task, remoteItems: syncResult.upserts, deletedItems: syncResult.deletes, since: since)
                logger.info("Notification sync finished for task: \(listServerId)")
                completion?()
            case .failure(let error):
                logger.error("Failed to sync notifications from server: \(error.localizedDescription)")
                completion?()
            }
        }
    }
    
    internal func syncNotifications(for task: TaskEntity, remoteItems: [NotificationUpsert], deletedItems: [NotificationDelete] = [], since: String?) {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        
        let localNotifications = ((task.notifications as? Set<NotificationEntity>) ?? []).sorted { ($0.target ?? .distantPast) < ($1.target ?? .distantPast) }

        // Handle deletes (remote deletions)
        let deletedIds = Set(deletedItems.map { $0.id })
        if !deletedIds.isEmpty {
            let toRemove = localNotifications.filter { entity in
                if let sid = entity.serverId { return deletedIds.contains(sid) } else { return false }
            }
            for entity in toRemove {
                context.delete(entity)
            }
        }
        // Map notifications by serverId for quick lookup
        var localByServerId: [String: NotificationEntity] = [:]
        for notif in localNotifications {
            if let serverId = notif.serverId {
                localByServerId[serverId] = notif
            }
        }

        for remote in remoteItems {
            if let localNotif = localByServerId[remote.id] {
                let updatedRemoteDate = Date.iso8601DateFormatter.date(from: remote.updatedAt) ?? .distantPast
                let updatedLocalDate = (localNotif.updatedAt ?? .distantPast).addingTimeInterval(1)
                if updatedRemoteDate > updatedLocalDate {
                    // Update fields
                    localNotif.type = remote.type
                    localNotif.target = Date.iso8601SecondsDateFormatter.date(from: remote.target)
                    localNotif.updatedAt = Date.iso8601DateFormatter.date(from: remote.updatedAt)
                } else {
                    self.updateNotification(localNotif)
                }
            } else {
                // Insert new NotificationEntity if does not exist
                let newNotif = NotificationEntity(context: context)
                newNotif.id = UUID()
                newNotif.serverId = remote.id
                newNotif.type = remote.type
                newNotif.target = Date.iso8601SecondsDateFormatter.date(from: remote.target)
                newNotif.updatedAt = Date.iso8601DateFormatter.date(from: remote.updatedAt)
                newNotif.task = task
            }
        }
        // Save context if there were changes
        do {
            try context.save()
        } catch {
            logger.error("Failed to save notifications context after sync: \(error.localizedDescription)")
        }
    }

    internal func createNotification(for task: TaskEntity, type: String, target: Date, completion: ((Result<String, Error>) -> Void)? = nil) {
        guard let listServerId = task.serverId, !listServerId.isEmpty else {
            logger.error("Can't create notification: task has no serverId")
            completion?(.failure(NSError(domain: "Notification", code: -1, userInfo: [NSLocalizedDescriptionKey: "No serverId for parent task."])))
            return
        }
        let targetString = Date.iso8601DateFormatter.string(from: target)
        self.createNotification(listId: listServerId, target: targetString, type: type) { result in
            switch result {
            case .success(let remoteItem):
                completion?(.success(remoteItem.id))
            case .failure(let error):
                logger.error("Failed to create notification on server: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }

    internal func updateNotification(_ notification: NotificationEntity, completion: ((Result<String, Error>) -> Void)? = nil) {
        guard let task = notification.task, let listServerId = task.serverId, let notifServerId = notification.serverId else {
            logger.error("Can't update notification: missing serverId or parent task")
            completion?(.failure(NSError(domain: "Notification", code: -3, userInfo: [NSLocalizedDescriptionKey: "No server id for task or item."])))
            return
        }
        let newType = notification.type ?? "default"
        let newTarget = notification.target ?? Date()
        let targetString = Date.iso8601DateFormatter.string(from: newTarget)
        self.updateNotification(listId: listServerId, id: notifServerId, target: targetString, type: newType) { result in
            switch result {
            case .success(let remoteItem):
                completion?(.success(remoteItem.id))
            case .failure(let error):
                logger.error("Failed to update notification on server: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }

    internal func deleteNotification(_ notification: NotificationEntity, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let task = notification.task, let listServerId = task.serverId, let notifServerId = notification.serverId else {
            logger.error("Can't delete notification: missing serverId or parent task")
            completion?(.failure(NSError(domain: "Notification", code: -4, userInfo: [NSLocalizedDescriptionKey: "No server id for task or item."])))
            return
        }
        self.deleteNotification(listId: listServerId, id: notifServerId) { result in
            switch result {
            case .success:
                completion?(.success(()))
            case .failure(let error):
                logger.error("Failed to delete notification on server: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }
}
