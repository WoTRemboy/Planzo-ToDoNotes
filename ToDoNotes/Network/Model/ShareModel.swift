//
//  ShareModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/09/2025.
//

struct ShareLink: Codable, Identifiable {
    let id: String
    let createdAt: String
    let expiresAt: String
    let revoked: Bool
    let scope: String
    let activeNow: Bool
}

struct SharesDelta: Codable {
    let upserts: [ShareLinkRequest]
    let deletes: [ShareDelete]
}

struct ShareLinkRequest: Codable, Identifiable {
    let id: String
    let listId: String
    let createdAt: String
    let expiresAt: String
    let revoked: Bool
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case id = "shareId"
        case listId, createdAt, expiresAt, revoked, scope
    }
}

struct ShareDelete: Codable {
    let shareId: String
    let listId: String
    let deletedAt: String
}
