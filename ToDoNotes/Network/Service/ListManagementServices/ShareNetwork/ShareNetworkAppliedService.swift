//
//  ShareNetworkAppliedService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 04/11/2025.
//

import Foundation
import CoreData
import OSLog
import UIKit

private let shareSyncLogger = Logger(subsystem: "com.todonotes.shares", category: "ShareNetworkAppliedService")

extension ShareNetworkService {
    /// Syncs share links for a backend task (list) with the server.
    internal func syncSharesIfNeeded(for task: TaskEntity, completion: (() -> Void)? = nil) {
        guard let listServerId = task.serverId, !listServerId.isEmpty else { completion?(); return }
        
        self.getShareInfo(for: listServerId) { result in
            switch result {
            case .success(let serverShares):
                self.syncShares(for: task, serverShares: serverShares)
                shareSyncLogger.info("Share sync finished for task: \(listServerId)")
                completion?()
            case .failure(let error):
                shareSyncLogger.error("Failed to sync shares from server: \(error.localizedDescription)")
                completion?()
            }
        }
    }
    
    internal func syncShares(for task: TaskEntity, serverShares: [ShareLink]) {
        // Map local shares by serverId
        let context = CoreDataProvider.shared.persistentContainer.viewContext

        let localShares = (ShareCoreDataService.shared.fetchShareEntities(for: task))
        var localByServerId: [String: ShareEntity] = [:]
        for share in localShares {
            if let serverId = share.serverId {
                localByServerId[serverId] = share
            }
        }
        let serverIds = Set(serverShares.map { $0.id })
        
        // Remove deleted shares
        for (serverId, entity) in localByServerId {
            if !serverIds.contains(serverId) {
                context.delete(entity)
            }
        }
        // Upsert or update shares
        for remote in serverShares {
            if let localShare = localByServerId[remote.id] {
                // Update local fields if needed
                localShare.scope = remote.scope
                localShare.activeNow = remote.activeNow
                localShare.revoked = remote.revoked
                localShare.createdAt = Date.iso8601DateFormatter.date(from: remote.createdAt)
                localShare.expiresAt = Date.iso8601DateFormatter.date(from: remote.expiresAt)
            } else {
                // Insert new ShareEntity
                _ = ShareCoreDataService.shared.saveShare(
                    serverId: remote.id,
                    scope: remote.scope,
                    activeNow: remote.activeNow,
                    revoked: remote.revoked,
                    createdAt: Date.iso8601DateFormatter.date(from: remote.createdAt),
                    expiresAt: Date.iso8601DateFormatter.date(from: remote.expiresAt),
                    task: task
                )
            }
        }
        do {
            try context.save()
        } catch {
            shareSyncLogger.error("Failed to save shares context after sync: \(error.localizedDescription)")
        }
    }
    
    /// Creates a share link on the server for a given task
    internal func createShare(for task: TaskEntity, expiresAt: String, completion: ((Result<String, Error>) -> Void)? = nil) {
        guard let listServerId = task.serverId, !listServerId.isEmpty else {
            shareSyncLogger.error("Can't create share: task has no serverId")
            completion?(.failure(NSError(domain: "Share", code: -1, userInfo: [NSLocalizedDescriptionKey: "No serverId for parent task."])));
            return
        }
        self.createShare(for: listServerId, expiresAt: expiresAt) { result in
            switch result {
            case .success(let shareLink):
                completion?(.success(shareLink.id))
            case .failure(let error):
                shareSyncLogger.error("Failed to create share on server: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }
    
    /// Deletes a share link from the server and local storage
    internal func deleteShare(_ share: ShareEntity, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let task = share.task, let listServerId = task.serverId, let shareServerId = share.serverId else {
            shareSyncLogger.error("Can't delete share: missing serverId or parent task")
            completion?(.failure(NSError(domain: "Share", code: -4, userInfo: [NSLocalizedDescriptionKey: "No server id for task or share."])));
            return
        }
        self.deleteShare(listId: listServerId, shareId: shareServerId) { result in
            switch result {
            case .success:
                ShareCoreDataService.shared.deleteShare(share)
                completion?(.success(()))
            case .failure(let error):
                shareSyncLogger.error("Failed to delete share on server: \(error.localizedDescription)")
                completion?(.failure(error))
            }
        }
    }
    
    /// Creates a share link on the server and presents a share sheet with the generated URL.
    internal func createShareAndPresentSheet(for task: TaskEntity, expiresAt: String, completion: ((Result<String, Error>) -> Void)? = nil) {
        self.createShare(for: task, expiresAt: expiresAt) { result in
            switch result {
            case .success(let serverID):
                let urlString = "https://banana.avoqode.com/l/\(serverID)"
                guard let url = URL(string: urlString) else { return }
                DispatchQueue.main.async {
                    guard let rootVC = RootViewControllerMethods.getRootViewController() else { return }
                    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    activityVC.popoverPresentationController?.sourceView = rootVC.view
                    rootVC.present(activityVC, animated: true, completion: nil)
                    completion?(.success(serverID))
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
