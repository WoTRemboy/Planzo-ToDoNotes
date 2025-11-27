//
//  UserCoreDataService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 02/10/2025.
//

import Foundation
import CoreData
import UIKit

final class UserCoreDataService {
    static let shared = UserCoreDataService()
    
    private var viewContext: NSManagedObjectContext {
        CoreDataProvider.shared.persistentContainer.viewContext
    }
    
    // MARK: - Save User
    
    internal func saveUser(_ user: User) {
        deleteUser()
        
        let entity = UserEntity(context: viewContext)
        entity.id = user.id
        entity.provider = user.provider
        entity.sub = user.sub
        entity.createdAt = Date.iso8601DateFormatter.date(from: user.createdAt ?? "")
        entity.name = user.name
        entity.email = user.email
        entity.avatarURL = user.avatarUrl
        entity.subscription = user.subscription.rawValue
        entity.lastSyncAt = user.lastSyncAt
        saveContext()
    }
    
    // MARK: - Load User
    
    internal func loadUser() -> User? {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        if let entity = try? viewContext.fetch(fetchRequest).first {
            let id = entity.id
            let provider = entity.provider
            let sub = entity.sub
            let createdAt = entity.createdAt
            let name = entity.name
            let email = entity.email
            let avatarURL = entity.avatarURL
            let subscription = entity.subscription
            let lastSyncAt = entity.lastSyncAt
            return User(
                id: id,
                provider: provider,
                sub: sub,
                createdAt: createdAt?.iso8601String,
                name: name,
                email: email,
                avatarUrl: avatarURL,
                subscription: SubscriptionType(rawValue: subscription ?? "free") ?? .free,
                lastSyncAt: lastSyncAt
            )
        }
        return nil
    }
    
    func updateLastSyncAt(date: Date = Date()) {
        guard var user = loadUser() else { return }
        let formatter = ISO8601DateFormatter()
        user.lastSyncAt = formatter.string(from: date)
        saveUser(user)
        NotificationCenter.default.post(name: .userDidUpdateLastSyncAt, object: user.lastSyncAt)
    }
    
    // MARK: - Delete User
    
    internal func deleteUser() {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        if let results = try? viewContext.fetch(fetchRequest) {
            for obj in results { viewContext.delete(obj) }
            saveContext()
        }
    }
    
    // MARK: - Helpers
    
    private func saveContext() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
}

// MARK: - ISO8601 Date Helpers

private extension Date {
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }
}

extension Notification.Name {
    static let userDidUpdateLastSyncAt = Notification.Name("userDidUpdateLastSyncAt")
}
