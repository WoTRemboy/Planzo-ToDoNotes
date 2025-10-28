//
//  ListItemNetworkService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 23/09/2025.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.todonotes.listing", category: "ListItemNetworkService")

final class ListItemNetworkService {
    static let shared = ListItemNetworkService()
    private let tokenStorage = TokenStorageService()

    /// Fetches items for a given list from the server, optionally since a specific date.
    /// - Parameters:
    ///   - listId: The ID of the list to fetch items for.
    ///   - since: String for incremental sync.
    ///   - completion: Completion handler with result containing ItemSyncResponse or error.
    func fetchItems(listId: String, since: String? = nil, completion: @escaping (Result<ItemSyncResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                var components = URLComponents(string: "https://banana.avoqode.com/api/v1/lists/\(listId)/items")!
                if let since = since {
                    components.queryItems = [URLQueryItem(name: "since", value: since)]
                }
                var request = URLRequest(url: components.url!)
                request.httpMethod = "GET"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Items fetch request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("Items fetch response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(ItemSyncResponse.self, from: data)
                        logger.info("Items fetch succeeded. Upserts: \(decoded.upserts.count), Deletes: \(decoded.deletes.count)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode items fetch response: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                task.resume()
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    /// Creates a new item in the specified list.
    /// - Parameters:
    ///   - listId: List id where to create the item
    ///   - title: Title of the item
    ///   - notes: Notes for the item
    ///   - dueAt: Due date
    ///   - completion: Completion handler with created ListTaskItem or error
    func createItem(for item: ChecklistEntity, listId: String, completion: @escaping (Result<ListTaskItem, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists/\(listId)/items") else {
                    logger.error("Invalid URL for item creation.")
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.badURL)))
                    }
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body = CreateItemRequest(title: item.name, notes: "", dueAt: nil)
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    logger.error("Failed to encode create item request: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Item create request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("Item create response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(ListTaskItem.self, from: data)
                        logger.info("Item create succeeded. ID: \(decoded.id)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode item create response: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                task.resume()
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    /// Deletes an item from the specified list.
    /// - Parameters:
    ///   - listId: List id
    ///   - id: Item id
    ///   - completion: Completion handler with success or error
    static func deleteItem(listId: String, id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists/\(listId)/items/\(id)") else {
                    logger.error("Invalid URL for item deletion.")
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.badURL)))
                    }
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Item delete request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    logger.info("Item delete succeeded. ID: \(id) in list \(listId)")
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                }
                task.resume()
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    /// Updates an item in the specified list.
    /// - Parameters:
    ///   - listId: List id
    ///   - id: Item id
    ///   - title: New title
    ///   - done: New done status
    ///   - notes: New notes
    ///   - dueAt: New due date
    ///   - completion: Completion handler with updated ListTaskItem or error
    func updateItem(listId: String, id: String, title: String? = nil, done: Bool? = nil, notes: String? = nil, dueAt: String? = nil, completion: @escaping (Result<ListTaskItem, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists/\(listId)/items/\(id)") else {
                    logger.error("Invalid URL for item update.")
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.badURL)))
                    }
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "PATCH"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body = UpdateItemRequest(title: title, done: done, notes: notes, dueAt: dueAt)
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    logger.error("Failed to encode update item request: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Item update request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("Item update response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(ListTaskItem.self, from: data)
                        logger.info("Item update succeeded. ID: \(decoded.id)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode item update response: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                task.resume()
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
