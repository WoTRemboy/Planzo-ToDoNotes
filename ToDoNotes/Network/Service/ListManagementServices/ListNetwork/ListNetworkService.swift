//
//  ListNetworkService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 22/09/2025.

import Foundation
import OSLog
import CoreData

private let logger = Logger(subsystem: "com.todonotes.listing", category: "ListNetworkService")

final class ListNetworkService {
    static let shared = ListNetworkService()
    private let tokenStorage = TokenStorageService()

    /// Fetches lists from the server, optionally since a specific date.
    /// - Parameters:
    ///   - since: String for incremental sync.
    ///   - completion: Completion handler with result containing ListSyncResponse or error.
    func fetchLists(since: String? = nil, completion: @escaping (Result<ListSyncResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                var components = URLComponents(string: "https://banana.avoqode.com/api/v1/lists")!
                if let since = since {
                    components.queryItems = [URLQueryItem(name: "since", value: since)]
                }
                var request = URLRequest(url: components.url!)
                request.httpMethod = "GET"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("List fetch request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("List fetch response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(ListSyncResponse.self, from: data)
                        logger.info("List fetch succeeded. Upserts: \(decoded.upserts.count), Deletes: \(decoded.deletes.count)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode list fetch response: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct CreateListRequest: Codable {
    let name: String?
    let details: String?
    let folder: String?
    let done: Bool
    let isTask: Bool
    let important: Bool
    let pinned: Bool
    let dueAt: String?
    let hasDueTime: Bool
}

struct UpdateListRequest: Codable {
    let id: String
    let name: String?
    let details: String?
    let folder: String?
    let done: Bool
    let isTask: Bool
    let important: Bool
    let pinned: Bool
    let dueAt: String?
    let hasDueTime: Bool
    let archived: Bool
}

extension ListNetworkService {
    /// Creates a new list on the server.
    /// - Parameters:
    ///   - name: The name for the new list.
    ///   - completion: Completion handler with result containing created ListItem or error.
    func createList(for task: TaskEntity, completion: @escaping (Result<ListItem, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists") else {
                    logger.error("Invalid URL for list creation.")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let dueAtString = task.target != nil ? Date.iso8601DateFormatter.string(from: task.target!) : nil
                let body = CreateListRequest(
                    name: task.name,
                    details: task.details,
                    folder: task.folder?.serverId,
                    done: task.completed == 2,
                    isTask: task.completed != 0,
                    important: task.important,
                    pinned: task.pinned,
                    dueAt: dueAtString,
                    hasDueTime: task.hasTargetTime)
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    logger.error("Failed to encode create list request: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("List create request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("List create response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(ListItem.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode list create response: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Updates an existing list on the server.
    /// - Parameters:
    ///   - task: The TaskEntity to update.
    ///   - completion: Completion handler with result containing updated ListItem or error.
    func updateList(to task: TaskEntity, completion: @escaping (Result<ListItem, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists/\(task.serverId ?? "")") else {
                    logger.error("Invalid URL for list update.")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "PATCH"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let dueAtString = task.target != nil ? Date.iso8601DateFormatter.string(from: task.target!) : nil
                let body = UpdateListRequest(
                    id: task.serverId ?? UUID().uuidString,
                    name: task.name,
                    details: task.details,
                    folder: task.folder?.serverId,
                    done: task.completed == 2,
                    isTask: task.completed != 0,
                    important: task.important,
                    pinned: task.pinned,
                    dueAt: dueAtString,
                    hasDueTime: task.hasTargetTime,
                    archived: task.removed)
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    logger.error("Failed to encode update list request: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("List update request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("List update response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(ListItem.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode list update response: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Deletes a list (task) from the server by id.
    /// - Parameters:
    ///   - id: The id of the list to delete.
    ///   - completion: Completion handler with result (Void or Error).
    func deleteList(withId id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists/\(id)") else {
                    logger.error("Invalid URL for list deletion.")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("List delete request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    logger.info("List delete succeeded. ID: \(id)")
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
