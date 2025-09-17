//
//  SubscriptionModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 16/09/2025.
//

internal enum SubscriptionType: String, Codable, Equatable {
    case free = "FreeSubscriptionType"
    case pro = "ProSubscriptionType"
    
    internal var title: String {
        switch self {
        case .free:
            return Texts.Subscription.SubType.free
        case .pro:
            return Texts.Subscription.SubType.pro
        }
    }
    
    internal var plan: String {
        switch self {
        case .free:
            return Texts.Subscription.SubType.freePlan
        case .pro:
            return Texts.Subscription.SubType.proPlan
        }
    }
}

extension User {
    internal var isPro: Bool { subscription == .pro }
    internal var isFree: Bool { subscription == .free }
    
    internal func withSubscription(_ newType: SubscriptionType) -> User {
        return User(
            id: id,
            provider: provider,
            sub: sub,
            createdAt: createdAt,
            name: name,
            email: email,
            avatarUrl: avatarUrl,
            subscription: newType
        )
    }
    
    mutating internal func changeSubscriptionType(to newType: SubscriptionType) {
        self = self.withSubscription(newType)
    }
}
