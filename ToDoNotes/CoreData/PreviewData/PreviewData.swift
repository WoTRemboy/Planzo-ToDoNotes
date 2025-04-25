//
//  PreviewData.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import Foundation
import CoreData

/// Provides mock or preview data for previews.
final class PreviewData {
    
    /// A sample task entity used in previews.
    static var taskItem: TaskEntity {
        let viewContext = CoreDataProvider.shared.persistentContainer.viewContext
        let request = TaskEntity.fetchRequest()
        return (try? viewContext.fetch(request).first) ?? TaskEntity()
    }
}
