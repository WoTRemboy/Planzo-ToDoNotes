//  ListNetworkService.swift
//  ToDoNotes
//
//  Created by Assistant on 22/09/2025.

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.todonotes.listing", category: "ListNetworkService")

// MARK: - List Models

struct ShareLink: Codable {
    let id: String
    let createdAt: String
    let expiresAt: String
    let revoked: Bool
    let scope: String
}

struct ListItem: Codable {
    let id: String
    let ownerSub: String
    let name: String
    let archived: Bool
    let updatedAt: String
    let shareLinks: [ShareLink]
}

struct ListDelete: Codable {
    let id: String
    let deletedAt: String
}

struct ListSyncResponse: Codable {
    let since: String
    let now: String
    let upserts: [ListItem]
    let deletes: [ListDelete]
}

// MARK: - List Network Service

final class ListNetworkService {
    static let shared = ListNetworkService()
    private let tokenStorage = TokenStorageService()

    /// Fetches lists from the server, optionally since a specific date.
    /// - Parameters:
    ///   - since: String for incremental sync.
    ///   - completion: Completion handler with result containing ListSyncResponse or error.
    func fetchLists(since: String? = nil, completion: @escaping (Result<ListSyncResponse, Error>) -> Void) {
        guard let accessToken = tokenStorage.load(type: .accessToken) else {
            logger.error("Missing access token when trying to fetch lists.")
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
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
                print(decoded)
            } catch {
                logger.error("Failed to decode list fetch response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

struct CreateListRequest: Codable {
    let name: String
}

struct UpdateListRequest: Codable {
    let id: String
    let name: String?
    let archived: Bool?
}

extension ListNetworkService {
    /// Creates a new list on the server.
    /// - Parameters:
    ///   - name: The name for the new list.
    ///   - completion: Completion handler with result containing created ListItem or error.
    func createList(name: String, completion: @escaping (Result<ListItem, Error>) -> Void) {
        guard let accessToken = tokenStorage.load(type: .accessToken) else {
            logger.error("Missing access token when trying to create list.")
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
        guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists") else {
            logger.error("Invalid URL for list creation.")
            completion(.failure(URLError(.badURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = CreateListRequest(name: name)
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
                logger.info("List create succeeded. ID: \(decoded.id)")
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
    }

    /// Updates an existing list on the server.
    /// - Parameters:
    ///   - id: The id of the list to update.
    ///   - name: New name for the list.
    ///   - archived: New archived value.
    ///   - completion: Completion handler with result containing updated ListItem or error.
    func updateList(id: String, name: String? = nil, archived: Bool? = nil, completion: @escaping (Result<ListItem, Error>) -> Void) {
        guard let accessToken = tokenStorage.load(type: .accessToken) else {
            logger.error("Missing access token when trying to update list.")
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
        guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists/\(id)") else {
            logger.error("Invalid URL for list update.")
            completion(.failure(URLError(.badURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = UpdateListRequest(id: id, name: name, archived: archived)
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
                logger.info("List update succeeded. ID: \(decoded.id)")
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
    }
}
