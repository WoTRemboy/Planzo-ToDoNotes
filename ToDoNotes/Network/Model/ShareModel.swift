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
