//
//  CoreDataViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/12/25.
//

import Foundation
import Combine
import CoreData

final class CoreDataViewModel: ObservableObject {
    
    @Published internal var savedEnities: [TaskEntity] = []
    private let container: NSPersistentContainer
    
    internal var isEmpty : Bool {
        savedEnities.isEmpty
    }
    
    init() {
        container = NSPersistentContainer(name: Texts.CoreData.container)
        container.loadPersistentStores { (description, error) in
            if let error {
                print("Error loading core data: \(error.localizedDescription)")
            } else {
                print("Successfully loaded core data")
            }
        }
        fetchTasks()
    }
    
    internal func addTask(name: String, description: String) {
        let newTask = TaskEntity(context: container.viewContext)
        
        newTask.id = UUID()
        newTask.name = name
        newTask.details = description
        saveData()
    }
    
    internal func deleteTask(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        
        let entity = savedEnities[index]
        container.viewContext.delete(entity)
        saveData()
    }
    
    private func saveData() {
        do {
            try container.viewContext.save()
            fetchTasks()
        } catch let error {
            print("Error saving data: \(error.localizedDescription)")
        }
    }
    
    private func fetchTasks() {
        let request = NSFetchRequest<TaskEntity>(entityName: Texts.CoreData.entity)
        
        do {
            savedEnities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching tasks: \(error.localizedDescription)")
        }
    }
}
