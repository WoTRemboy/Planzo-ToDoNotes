//
//  PreviewData.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import Foundation
import CoreData

final class PreviewData {
    
    static var taskItem: TaskEntity {
        let viewContext = CoreDataProvider.shared.persistentContainer.viewContext
        let request = TaskEntity.fetchRequest()
        return (try? viewContext.fetch(request).first) ?? TaskEntity()
    }
}
