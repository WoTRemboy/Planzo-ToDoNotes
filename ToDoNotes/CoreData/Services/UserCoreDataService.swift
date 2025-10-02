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
        entity.createdAt = ISO8601DateFormatter().date(from: user.createdAt)
        entity.name = user.name
        entity.email = user.email
        entity.avatarURL = user.avatarUrl
        entity.subscription = user.subscription.rawValue
        saveContext()
    }
    
    // MARK: - Load User
    
    internal func loadUser() -> User? {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        if let entity = try? viewContext.fetch(fetchRequest).first {
            return User(
                id: entity.id ?? "",
                provider: entity.provider ?? "",
                sub: entity.sub ?? "",
                createdAt: entity.createdAt?.iso8601String ?? "",
                name: entity.name,
                email: entity.email,
                avatarUrl: entity.avatarURL,
                subscription: SubscriptionType(rawValue: entity.subscription ?? "free") ?? .free
            )
        }
        return nil
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
