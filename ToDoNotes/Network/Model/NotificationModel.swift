//
//  NotificationModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 31/10/2025.
//

struct NotificationUpsert: Codable {
    let id: String
    let listId: String
    let target: String
    let type: String
    let updatedAt: String
    let updatedBy: String?
    let deleted: Bool
    let deletedAt: String?
}

struct NotificationDelete: Codable {
    let id: String
    let deletedAt: String
}

struct NotificationSyncResponse: Codable {
    let since: String
    let now: String
    let upserts: [NotificationUpsert]
    let deletes: [NotificationDelete]
}

struct CreateNotificationRequest: Codable {
    let target: String
    let type: String
}

struct UpdateNotificationRequest: Codable {
    let target: String
    let type: String
    let deleted: Bool?
}
