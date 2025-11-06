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

struct FullSyncSnapshotResponse: Codable {
    let now: String
    let nextCursor: String?
    let folders: [FolderUpsert]
    let lists: [ListItem]
    let items: [ListTaskItem]
    let shares: [ShareLinkRequest]
}

final class FullSyncNetworkService {
    static let shared = FullSyncNetworkService()
    
    func syncAllData(completion: @escaping (Result<Void, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/sync/snapshot") else {
                    logger.error("Invalid URL for full sync.")
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
                        DispatchQueue.main.async { completion(.failure(error)) }
                        return
                    }
                    guard let data = data else {
                        logger.error("Full sync response data is nil.")
                        DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(FullSyncSnapshotResponse.self, from: data)
                        logger.info("Full sync succeeded. Folders: \(decoded.folders.count), Lists: \(decoded.lists.count), Items: \(decoded.items.count), Shares: \(decoded.shares.count)")
                        ListNetworkService.shared.syncLists(decoded.lists)
                        self.syncItems(decoded.items)
                        self.syncShares(decoded.shares)
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    } catch {
                        logger.error("Failed to decode full sync response: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Helper stubs for saving entities to Core Data
    
    private func syncItems(_ items: [ListTaskItem], deletedItems: [ItemDelete] = []) {
        guard !items.isEmpty else { return }
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let grouped = Dictionary(grouping: items, by: { $0.listId })
        context.performAndWait {
            for (listId, itemsGroup) in grouped {
                let fetch: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                fetch.predicate = NSPredicate(format: "serverId == %@", listId)
                fetch.fetchLimit = 1
                if let task = try? context.fetch(fetch).first {
                    ListItemNetworkService.shared.syncItems(for: task, remoteItems: itemsGroup, since: nil)
                } else {
                    logger.error("No TaskEntity found for listId: \(listId)")
                }
            }
        }
    }
    private func syncShares(_ shares: [ShareLinkRequest]) {
        guard !shares.isEmpty else { return }
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let grouped = Dictionary(grouping: shares, by: { $0.listId })
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
                            activeNow: true
                        )
                    }
                    ShareNetworkService.shared.syncShares(for: task, serverShares: shareLinks)
                } else {
                    logger.error("No TaskEntity found for listId: \(listId)")
                }
            }
        }
    }
}
