//
//  NotificationNetworkService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 31/10/2025.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.todonotes.notifications", category: "NotificationNetworkService")

// MARK: - Network Service

final class NotificationNetworkService {
    static let shared = NotificationNetworkService()

    /// Fetches notifications for a given list from the server, optionally since a specific date.
    /// - Parameters:
    ///   - listId: The ID of the list to fetch notifications for.
    ///   - since: String for incremental sync.
    ///   - completion: Completion handler with result containing NotificationSyncResponse or error.
    func fetchNotifications(listId: String, since: String? = nil, completion: @escaping (Result<NotificationSyncResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                var components = URLComponents(string: "https://banana.avoqode.com/api/v1/lists/\(listId)/notifications")!
                if let since = since {
                    components.queryItems = [URLQueryItem(name: "since", value: since)]
                }
                var request = URLRequest(url: components.url!)
                request.httpMethod = "GET"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Notifications fetch request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("Notifications fetch response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(NotificationSyncResponse.self, from: data)
                        logger.info("Notifications fetch succeeded. Upserts: \(decoded.upserts.count), Deletes: \(decoded.deletes.count)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode notifications fetch response: \(error.localizedDescription)")
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

    /// Creates a new notification in the specified list.
    /// - Parameters:
    ///   - listId: List id where to create the notification
    ///   - target: Notification trigger date/time (ISO8601 string)
    ///   - type: Notification type string
    ///   - completion: Completion handler with created NotificationUpsert or error
    func createNotification(listId: String, target: String, type: String, completion: @escaping (Result<NotificationUpsert, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists/\(listId)/notifications") else {
                    logger.error("Invalid URL for notification creation.")
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.badURL)))
                    }
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body = CreateNotificationRequest(target: target, type: type)
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    logger.error("Failed to encode create notification request: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Notification create request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("Notification create response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(NotificationUpsert.self, from: data)
                        logger.info("Notification create succeeded. ID: \(decoded.id)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode notification create response: \(error.localizedDescription)")
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
    
    /// Deletes a notification from the specified list.
    /// - Parameters:
    ///   - listId: List id
    ///   - id: Notification id
    ///   - completion: Completion handler with success or error
    func deleteNotification(listId: String, id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists/\(listId)/notifications/\(id)") else {
                    logger.error("Invalid URL for notification deletion.")
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
                        logger.error("Notification delete request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    logger.info("Notification delete succeeded. ID: \(id) in list \(listId)")
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

    /// Updates a notification in the specified list.
    /// - Parameters:
    ///   - listId: List id
    ///   - id: Notification id
    ///   - target: Notification trigger date/time (ISO8601 string)
    ///   - type: Notification type string
    ///   - deleted: Deleted flag (optional)
    ///   - completion: Completion handler with updated NotificationUpsert or error
    func updateNotification(listId: String, id: String, target: String, type: String, deleted: Bool? = nil, completion: @escaping (Result<NotificationUpsert, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/lists/\(listId)/notifications/\(id)") else {
                    logger.error("Invalid URL for notification update.")
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.badURL)))
                    }
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "PATCH"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let body = UpdateNotificationRequest(target: target, type: type, deleted: deleted)
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    logger.error("Failed to encode update notification request: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Notification update request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("Notification update response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(NotificationUpsert.self, from: data)
                        logger.info("Notification update succeeded. ID: \(decoded.id)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode notification update response: \(error.localizedDescription)")
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
