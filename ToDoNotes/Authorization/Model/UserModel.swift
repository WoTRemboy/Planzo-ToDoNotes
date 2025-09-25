//
//  UserModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 03/09/2025.
//

/// Represents the user information returned by the authorization response.
internal struct User: Codable, Equatable {
    let id: String
    let provider: String
    let sub: String
    let createdAt: String
    let name: String?
    let email: String?
    let avatarUrl: String?
    let subscription: SubscriptionType
    
    private enum CodingKeys: String, CodingKey {
        case id, provider, sub, createdAt, name, email, avatarUrl, subscription
    }
    
    internal init(id: String, provider: String, sub: String, createdAt: String, name: String? = nil, email: String? = nil, avatarUrl: String? = nil, subscription: SubscriptionType = .free) {
        self.id = id
        self.provider = provider
        self.sub = sub
        self.createdAt = createdAt
        self.name = name
        self.email = email
        self.avatarUrl = avatarUrl
        self.subscription = subscription
    }
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        provider = try container.decode(String.self, forKey: .provider)
        sub = try container.decode(String.self, forKey: .sub)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        subscription = try container.decodeIfPresent(SubscriptionType.self, forKey: .subscription) ?? .free
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
