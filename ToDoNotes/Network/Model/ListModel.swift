//
//  ListModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/09/2025.
//

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
