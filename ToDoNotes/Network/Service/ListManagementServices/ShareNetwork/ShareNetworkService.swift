//
//  ShareNetworkService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 24/09/2025.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.todonotes.opening", category: "ShareNetworkService")

final class ShareNetworkService: ObservableObject {
    static let shared = ShareNetworkService()
    private let baseURL = "https://banana.avoqode.com/api/v1/lists/"
    
    /// Loads share info for a list by id.
    func getShareInfo(for listId: String, completion: @escaping (Result<[ShareLink], Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: self.baseURL + "\(listId)/share") else {
                    logger.error("Invalid share URL for listId: \(listId)")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Share info request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("Share info response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode([ShareLink].self, from: data)
                        logger.info("Share info loaded for listId: \(listId)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode share info: \(error.localizedDescription)")
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
    
    /// Creates share info for a list by id
    func createShare(for listId: String, expiresAt: String, grantRole: String, completion: @escaping (Result<ShareLink, Error>) -> Void) {
        struct Body: Codable {
            let expiresAt: String
            let grantRole: String?
            let oneTime: Bool?
            let maxUses: Int?

            enum CodingKeys: String, CodingKey {
                case expiresAt
                case grantRole
                case oneTime
                case maxUses
            }
        }
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: self.baseURL + "\(listId)/share") else {
                    logger.error("Invalid share URL for listId: \(listId)")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let body = Body(expiresAt: expiresAt, grantRole: grantRole, oneTime: true, maxUses: 1)
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    logger.error("Failed to encode share POST body: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Share POST request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        logger.error("Share POST response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(ShareLink.self, from: data)
                        logger.info("Share link created for listId: \(listId)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        logger.error("Failed to decode share POST response: \(error.localizedDescription)")
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
    
    /// Deletes a share link for a list by id and share id
    func deleteShare(listId: String, shareId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: self.baseURL + "\(listId)/share/\(shareId)") else {
                    logger.error("Invalid delete share URL: listId=\(listId), shareId=\(shareId)")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Share DELETE request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse else {
                        logger.error("Share DELETE response is not HTTPURLResponse.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    if httpResponse.statusCode == 204 {
                        logger.info("Share link deleted for listId: \(listId), shareId: \(shareId)")
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    } else {
                        logger.error("Share DELETE failed with status: \(httpResponse.statusCode)")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.cannotRemoveFile)))
                        }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Accepts a share invite by code
    /// - Parameters:
    ///   - code: Share code received from the inviter
    ///   - completion: Result with Void on success, or Error
    func acceptShare(code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        struct Body: Codable { let code: String }
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/share/accept") else {
                    logger.error("Invalid accept share URL")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

                let body = Body(code: code)
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    logger.error("Failed to encode accept share body: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Accept share request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse else {
                        logger.error("Accept share response is not HTTPURLResponse.")
                        DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                        return
                    }

                    if (200...299).contains(httpResponse.statusCode) {
                        logger.info("Share accepted successfully")
                        DispatchQueue.main.async { completion(.success(())) }
                    } else {
                        if let data = data, let message = String(data: data, encoding: .utf8) {
                            logger.error("Accept share failed (status: \(httpResponse.statusCode)) body: \(message)")
                        } else {
                            logger.error("Accept share failed with status: \(httpResponse.statusCode)")
                        }
                        DispatchQueue.main.async { completion(.failure(URLError(.cannotParseResponse))) }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
