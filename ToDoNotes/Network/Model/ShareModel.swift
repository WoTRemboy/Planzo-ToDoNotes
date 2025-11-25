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
    let grantRole: String
    let oneTime: Bool
    let maxUses: Int
    let useCount: Int
    let usedAt: String?
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
    let grantRole: String
    let oneTime: Bool
    let maxUses: Int
    let useCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "shareId"
        case listId, createdAt, expiresAt, revoked, scope
        case grantRole, oneTime, maxUses, useCount
    }
}

struct ShareDelete: Codable {
    let shareId: String
    let listId: String
    let deletedAt: String
}

struct SharingMember: Codable, Identifiable, Equatable {
    let id: String
    let listId: String
    let userSub: String
    let role: String
    let revoked: Bool
    let addedAt: String
    let addedBy: String
    let updatedAt: String
    
    static var mock: Self {
        SharingMember(id: "691b9afeea81264114031374", listId: "345", userSub: "000546.56ddf35528724485a1665f236097c44a.1446", role: ShareAccess.viewOnly.rawValue, revoked: false, addedAt: "", addedBy: "", updatedAt: "")
    }
}

enum ShareAccess: String {
    case owner = "OWNER"
    case viewOnly = "VIEWER"
    case edit = "EDITOR"
    case closed = "NO_ACCESS"
    
    internal var name: String {
        switch self {
        case .owner:
            return Texts.TaskManagement.ShareView.Access.owner
        case .viewOnly:
            return Texts.TaskManagement.ShareView.Access.view
        case .edit:
            return Texts.TaskManagement.ShareView.Access.edit
        case .closed:
            return Texts.TaskManagement.ShareView.Access.closeAccess
        }
    }
    
    internal var description: String {
        switch self {
        case .owner:
            return Texts.TaskManagement.ShareView.Access.ownerDisctiption
        case .viewOnly:
            return Texts.TaskManagement.ShareView.Access.viewDisctiption
        case .edit:
            return Texts.TaskManagement.ShareView.Access.editDescription
        case .closed:
            return Texts.TaskManagement.ShareView.Access.closeDescription
        }
    }
}

struct MyRoleResponse: Codable {
    let role: String
}
