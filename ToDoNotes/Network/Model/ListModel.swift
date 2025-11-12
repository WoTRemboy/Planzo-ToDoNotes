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
    let createdAt: String
    let updatedAt: String
    let shareLinks: [ShareLink]
    let details: String?
    let folder: String?
    let done: Bool
    let isTask: Bool
    let important: Bool
    let pinned: Bool
    let dueAt: String?
    let hasDueTime: Bool
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

struct ListsDelta: Codable {
    let upserts: [ListItem]
    let deletes: [ListDelete]
}

enum SyncStatus {
    case updating
    case updated
    case failed
}
