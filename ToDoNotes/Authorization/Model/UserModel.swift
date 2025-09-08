//
//  UserModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 03/09/2025.
//

/// Represents the user information returned by the authorization response.
internal struct User: Codable {
    let id: String
    let provider: String
    let sub: String
    let createdAt: String
    let name: String?
    let email: String?
    let avatarUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, provider, sub, createdAt, name, email, avatarUrl
    }
}

/// Represents the structure of the response returned by the authorization endpoint.
internal struct AuthResponse: Codable {
    let accessToken: String
    let accessTokenExpiresAt: String
    let refreshToken: String
    let refreshTokenExpiresAt: String
    let tokenType: String
    let user: User
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case accessTokenExpiresAt = "accessTokenExpiresAt"
        case refreshToken = "refreshToken"
        case refreshTokenExpiresAt = "refreshTokenExpiresAt"
        case tokenType = "tokenType"
        case user
    }
}
