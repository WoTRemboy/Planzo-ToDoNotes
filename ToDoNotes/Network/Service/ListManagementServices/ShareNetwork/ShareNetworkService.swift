//
//  ShareNetworkService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 24/09/2025.
//

import Foundation
import OSLog

private let shareLogger = Logger(subsystem: "com.todonotes.opening", category: "ShareNetworkService")

final class ShareNetworkService: ObservableObject {
    static let shared = ShareNetworkService()
    private let tokenStorage = TokenStorageService()
    private let baseURL = "https://banana.avoqode.com/api/v1/lists/"
    
    /// Loads share info for a list by id.
    func getShareInfo(for listId: String, completion: @escaping (Result<[ShareLink], Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: self.baseURL + "\(listId)/share") else {
                    shareLogger.error("Invalid share URL for listId: \(listId)")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        shareLogger.error("Share info request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        shareLogger.error("Share info response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode([ShareLink].self, from: data)
                        shareLogger.info("Share info loaded for listId: \(listId)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        shareLogger.error("Failed to decode share info: \(error.localizedDescription)")
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
    func createShare(for listId: String, expiresAt: String, completion: @escaping (Result<ShareLink, Error>) -> Void) {
        struct Body: Codable { let expiresAt: String }
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: self.baseURL + "\(listId)/share") else {
                    shareLogger.error("Invalid share URL for listId: \(listId)")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let body = Body(expiresAt: expiresAt)
                do {
                    request.httpBody = try JSONEncoder().encode(body)
                } catch {
                    shareLogger.error("Failed to encode share POST body: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        shareLogger.error("Share POST request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        shareLogger.error("Share POST response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(ShareLink.self, from: data)
                        shareLogger.info("Share link created for listId: \(listId)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        shareLogger.error("Failed to decode share POST response: \(error.localizedDescription)")
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
                    shareLogger.error("Invalid delete share URL: listId=\(listId), shareId=\(shareId)")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        shareLogger.error("Share DELETE request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse else {
                        shareLogger.error("Share DELETE response is not HTTPURLResponse.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    if httpResponse.statusCode == 204 {
                        shareLogger.info("Share link deleted for listId: \(listId), shareId: \(shareId)")
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    } else {
                        shareLogger.error("Share DELETE failed with status: \(httpResponse.statusCode)")
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
}
