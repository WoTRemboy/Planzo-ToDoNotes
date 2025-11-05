//
//  FolderNetworkModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 05/11/2025.
//

struct FolderUpsert: Codable {
    let id: String
    let name: String
    let order: Int
    let shared: Bool
    let system: Bool
    let visible: Bool
    let locked: Bool
    let color: FolderColor
    let createdAt: String
    let updatedAt: String
}

struct FolderDelete: Codable {
    let id: String
    let deletedAt: String
}

struct FolderSyncResponse: Codable {
    let since: String
    let now: String
    let upserts: [FolderUpsert]
    let deletes: [FolderDelete]
}

struct CreateFolderRequest: Codable {
    let name: String
    let order: Int
    let shared: Bool
    let system: Bool
    let visible: Bool
    let locked: Bool
    let color: FolderColor
}

struct UpdateFolderRequest: Codable {
    let name: String
    let order: Int
    let shared: Bool
    let system: Bool
    let visible: Bool
    let locked: Bool
    let color: FolderColor
}
