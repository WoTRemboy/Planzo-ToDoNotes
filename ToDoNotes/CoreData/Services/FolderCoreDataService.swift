//
//  FolderCoreDataService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 22/10/2025.
//

import Foundation
import CoreData
import UIKit

final class FolderCoreDataService {
    static let shared = FolderCoreDataService()
    
    private var viewContext: NSManagedObjectContext {
        CoreDataProvider.shared.persistentContainer.viewContext
    }
    
    // MARK: - Save Folder
    
    internal func saveFolder(_ folder: Folder, color: FolderColor) {
        deleteFolder(by: folder.id)
        
        let entity = FolderEntity(context: viewContext)
        entity.id = folder.id
        entity.name = folder.name
        entity.locked = folder.locked
        entity.serverId = folder.serverId
        entity.visible = folder.visible
        entity.order = Int32(folder.order)
        
        // Создаём/обновляем цвет
        let colorEntity = ColorEntity(context: viewContext)
        colorEntity.red = color.red
        colorEntity.green = color.green
        colorEntity.blue = color.blue
        colorEntity.alpha = color.alpha
        colorEntity.folder = entity
        entity.color = colorEntity
        
        saveContext()
    }
    
    // MARK: - Load Folders
    
    internal func loadFolders() -> [Folder] {
        let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        if let entities = try? viewContext.fetch(fetchRequest) {
            return entities.map { Folder(from: $0) }
        }
        return []
    }
    
    internal func loadFolder(by id: UUID) -> Folder? {
        let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        if let entity = try? viewContext.fetch(fetchRequest).first {
            return Folder(from: entity)
        }
        return nil
    }
    
    // MARK: - Delete Folder
    
    internal func deleteFolder(by id: UUID) {
        let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let results = try? viewContext.fetch(fetchRequest) {
            for obj in results {
                if let color = obj.color {
                    viewContext.delete(color)
                }
                viewContext.delete(obj)
            }
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

// MARK: - Entity to Model Mapping

extension Folder {
    init(from entity: FolderEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.locked = entity.locked
        self.serverId = entity.serverId ?? ""
        self.visible = entity.visible
        self.order = Int(entity.order)
        if let colorEntity = entity.color {
            self.color = FolderColor(
                red: colorEntity.red,
                green: colorEntity.green,
                blue: colorEntity.blue,
                alpha: colorEntity.alpha
            )
        } else {
            self.color = FolderColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}

// MARK: - Folder & FolderColor Models

struct Folder {
    var id: UUID
    var name: String
    var locked: Bool
    var serverId: String
    var visible: Bool
    var color: FolderColor
    var order: Int
}

struct FolderColor {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
}
