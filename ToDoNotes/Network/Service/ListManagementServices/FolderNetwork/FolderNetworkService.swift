//
//  FolderNetworkService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 05/11/2025.

import Foundation
import OSLog

private let folderLogger = Logger(subsystem: "com.todonotes.foldering", category: "FolderNetworkService")

final class FolderNetworkService {
    static let shared = FolderNetworkService()
    private let tokenStorage = TokenStorageService()

    // MARK: - Fetch
    func fetchFolders(since: String?, completion: @escaping (Result<FolderSyncResponse, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                var components = URLComponents(string: "https://banana.avoqode.com/api/v1/folders")!
                if let since = since {
                    components.queryItems = [URLQueryItem(name: "since", value: since)]
                }
                var request = URLRequest(url: components.url!)
                request.httpMethod = "GET"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        folderLogger.error("Folder fetch request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        folderLogger.error("Folder fetch response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(FolderSyncResponse.self, from: data)
                        folderLogger.info("Folder fetch succeeded. Upserts: \(decoded.upserts.count), Deletes: \(decoded.deletes.count)")
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        folderLogger.error("Failed to decode folder fetch response: \(error.localizedDescription)")
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

    // MARK: - Create
    func createFolder(requestModel: CreateFolderRequest, completion: @escaping (Result<FolderUpsert, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/folders") else {
                    folderLogger.error("Invalid URL for folder creation.")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                do {
                    request.httpBody = try JSONEncoder().encode(requestModel)
                } catch {
                    folderLogger.error("Failed to encode create folder request: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        folderLogger.error("Folder create request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        folderLogger.error("Folder create response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(FolderUpsert.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        folderLogger.error("Failed to decode folder create response: \(error.localizedDescription)")
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

    // MARK: - Update
    func updateFolder(id: String, requestModel: UpdateFolderRequest, completion: @escaping (Result<FolderUpsert, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/folders/\(id)") else {
                    folderLogger.error("Invalid URL for folder update.")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "PATCH"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                do {
                    request.httpBody = try JSONEncoder().encode(requestModel)
                } catch {
                    folderLogger.error("Failed to encode update folder request: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        folderLogger.error("Folder update request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    guard let data = data else {
                        folderLogger.error("Folder update response data is nil.")
                        DispatchQueue.main.async {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(FolderUpsert.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        folderLogger.error("Failed to decode folder update response: \(error.localizedDescription)")
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

    // MARK: - Delete
    func deleteFolder(withId id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: "https://banana.avoqode.com/api/v1/folders/\(id)") else {
                    folderLogger.error("Invalid URL for folder deletion.")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        folderLogger.error("Folder delete request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                        return
                    }
                    folderLogger.info("Folder delete succeeded. ID: \(id)")
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
