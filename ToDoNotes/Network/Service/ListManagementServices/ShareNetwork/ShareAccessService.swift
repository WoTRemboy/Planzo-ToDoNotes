//
//  ShareAccessService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 18/11/2025.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.todonotes.sharing", category: "ShareAccessService")

final class ShareAccessService: ObservableObject {
    static let shared = ShareAccessService()
    private let baseURL = "https://banana.avoqode.com/api/v1/lists/"

    /// Loads members for a list by id.
    func getMembers(for listId: String, completion: @escaping (Result<[SharingMember], Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: self.baseURL + "\(listId)/members") else {
                    logger.error("Invalid members URL for listId: \(listId)")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Members fetch failed: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                        return
                    }
                    guard let data = data else {
                        logger.error("Members fetch response data is nil.")
                        DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                        return
                    }
                    print(String(data: data, encoding: .utf8)!)
                    do {
                        let decoded = try JSONDecoder().decode([SharingMember].self, from: data)
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        logger.error("Failed to decode members: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Deletes a member from a list by their id
    func deleteMember(listId: String, memberId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        AccessTokenManager.shared.getValidAccessToken { result in
            switch result {
            case .success(let accessToken):
                guard let url = URL(string: self.baseURL + "\(listId)/members/\(memberId)") else {
                    logger.error("Invalid delete member URL: listId=\(listId), memberId=\(memberId)")
                    completion(.failure(URLError(.badURL)))
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        logger.error("Member DELETE request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse else {
                        logger.error("Member DELETE response is not HTTPURLResponse.")
                        DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                        return
                    }
                    if httpResponse.statusCode == 200 {
                        DispatchQueue.main.async { completion(.success(())) }
                    } else {
                        logger.error("Member DELETE failed with status: \(httpResponse.statusCode)")
                        DispatchQueue.main.async { completion(.failure(URLError(.cannotRemoveFile))) }
                    }
                }
                task.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
