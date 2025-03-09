//
//  CoreDataProvider.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import Foundation
import CoreData

final class CoreDataProvider {
    
    static let shared = CoreDataProvider()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: Texts.CoreData.container)
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Error initializing Core Data: \(error), \(error.userInfo)")
            } else {
                print("Successfully loaded core data")
            }
        }
    }
}
