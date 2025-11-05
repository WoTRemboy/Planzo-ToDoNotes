//
//  ListItemModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 27/09/2025.
//

struct ListTaskItem: Codable {
    let id: String
    let listId: String
    let title: String?
    let done: Bool
    let notes: String?
    let dueAt: String?
    let order: Int
    let updatedAt: String
    let updatedBy: String
    let deleted: Bool
    let deletedAt: String?
}

struct ItemDelete: Codable {
    let id: String
    let deletedAt: String
}

struct ItemSyncResponse: Codable {
    let since: String
    let now: String
    let upserts: [ListTaskItem]
    let deletes: [ItemDelete]
}

struct CreateItemRequest: Codable {
    let title: String?
    let notes: String?
    let dueAt: String?
    let order: Int
    let done: Bool
}

struct UpdateItemRequest: Codable {
    let title: String?
    let done: Bool
    let notes: String?
    let dueAt: String?
    let order: Int
}
