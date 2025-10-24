//
//  FolderCoreDataService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 22/10/2025.
//

import Foundation
import CoreData
import SwiftUI

final class FolderCoreDataService {
    static let shared = FolderCoreDataService()
    
    private var viewContext: NSManagedObjectContext {
        CoreDataProvider.shared.persistentContainer.viewContext
    }
    
    static func createDefaultFoldersIfNeeded() {
        let key = Texts.UserDefaults.didCreateDefaultFolders
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: key) else { return }
        
        for folderEnum in FolderEnum.allCases {
            let color = FolderCoreDataService.colorForFolderEnum(folderEnum)
            let folder = Folder(
                id: UUID(),
                name: folderEnum.name,
                locked: false,
                serverId: "",
                system: folderEnum.system,
                shared: folderEnum == .shared,
                visible: true,
                color: color,
                order: FolderEnum.allCases.firstIndex(of: folderEnum) ?? 0
            )
            FolderCoreDataService.shared.saveFolder(folder, color: color)
        }
        defaults.set(true, forKey: key)
    }
    
    private static func colorForFolderEnum(_ folder: FolderEnum) -> FolderColor {
        FolderColor.colorToRgb(folder.color)
    }
    
    // MARK: - Save Folder
    
    internal func saveFolder(_ folder: Folder, color: FolderColor) {
        deleteFolder(by: folder.id)
        
        let entity = FolderEntity(context: viewContext)
        entity.id = folder.id
        entity.name = folder.name
        entity.locked = folder.locked
        entity.serverId = folder.serverId
        entity.system = folder.system
        entity.shared = folder.shared
        entity.visible = folder.visible
        entity.order = Int32(folder.order)
        
        let colorEntity = ColorEntity(context: viewContext)
        colorEntity.red = color.red
        colorEntity.green = color.green
        colorEntity.blue = color.blue
        colorEntity.alpha = color.alpha
        colorEntity.folder = entity
        entity.color = colorEntity
        
        saveContext()
    }
    
    internal func updateFolder(_ folder: Folder, color: FolderColor) {
        let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", folder.id as CVarArg)
        fetchRequest.fetchLimit = 1
        if let entity = try? viewContext.fetch(fetchRequest).first {
            entity.name = folder.name
            entity.locked = folder.locked
            entity.serverId = folder.serverId
            entity.system = folder.system
            entity.shared = folder.shared
            entity.visible = folder.visible
            entity.order = Int32(folder.order)
            if let colorEntity = entity.color {
                colorEntity.red = color.red
                colorEntity.green = color.green
                colorEntity.blue = color.blue
                colorEntity.alpha = color.alpha
            } else {
                let colorEntity = ColorEntity(context: viewContext)
                colorEntity.red = color.red
                colorEntity.green = color.green
                colorEntity.blue = color.blue
                colorEntity.alpha = color.alpha
                colorEntity.folder = entity
                entity.color = colorEntity
            }
            saveContext()
        }
    }
    
    // MARK: - Load Folders
    
    /// Loads folders from Core Data.
    /// - Parameter onlySystem: If true, loads only system folders; if false, loads only non-system; if nil, loads all folders.
    internal func loadFolders(onlySystem: Bool? = nil) -> [Folder] {
        let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        if let onlySystem = onlySystem {
            fetchRequest.predicate = NSPredicate(format: "system == %@", NSNumber(value: onlySystem))
        }
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
        self.system = entity.system
        self.shared = entity.shared
        self.visible = entity.visible
        self.order = Int(entity.order)
        if let colorEntity = entity.color {
            self.color = FolderColor(from: colorEntity)
        } else {
            self.color = FolderColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}

extension FolderColor {
    init(from entity: ColorEntity) {
        self.red = entity.red
        self.green = entity.green
        self.blue = entity.blue
        self.alpha = entity.alpha
    }
}
