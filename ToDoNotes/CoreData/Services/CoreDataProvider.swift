//
//  CoreDataProvider.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import Foundation
import CoreData
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "CoreDataProvider", category: "CoreData")

/// A singleton class responsible for setting up and managing the Core Data.
final class CoreDataProvider {
    
    /// Shared singleton instance of `CoreDataProvider`.
    static let shared = CoreDataProvider()
    /// The main Core Data container used to load and manage the persistent store.
    let persistentContainer: NSPersistentContainer
    
    /// Private initializer to enforce singleton usage and load the Core Data stack.
    private init() {
        // Initializes the container with the model name from constants
        persistentContainer = NSPersistentContainer(name: Texts.CoreData.container)
        
        // Loads the persistent store and handles any initialization errors
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // Crashes the app in case of a Core Data setup failure
                fatalError("Error initializing Core Data: \(error), \(error.userInfo)")
            } else {
                // Logs a successful load
                logger.info("Successfully loaded core data.")
            }
        }
    }
}
