//
//  FetchControllers.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/13/26.
//

import Foundation
import CoreData

final class TaskFetchController: NSObject, NSFetchedResultsControllerDelegate {
    static let defaultSortDescriptors: [NSSortDescriptor] = [
        NSSortDescriptor(key: "target", ascending: true),
        NSSortDescriptor(key: "created", ascending: true)
    ]

    var onUpdate: (([TaskEntity]) -> Void)?

    private let context: NSManagedObjectContext
    private let fetchBatchSize: Int
    private var controller: NSFetchedResultsController<TaskEntity>?

    init(
        context: NSManagedObjectContext = CoreDataProvider.shared.persistentContainer.viewContext,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = TaskFetchController.defaultSortDescriptors,
        fetchBatchSize: Int = 200
    ) {
        self.context = context
        self.fetchBatchSize = fetchBatchSize
        super.init()
        configureController(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func start() {
        performFetch()
    }

    func update(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor] = TaskFetchController.defaultSortDescriptors
    ) {
        configureController(predicate: predicate, sortDescriptors: sortDescriptors)
        performFetch()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tasks = controller.fetchedObjects as? [TaskEntity] else { return }
        onUpdate?(tasks)
    }

    private func configureController(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.fetchBatchSize = fetchBatchSize

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.controller = controller
    }

    private func performFetch() {
        do {
            try controller?.performFetch()
            if let tasks = controller?.fetchedObjects {
                onUpdate?(tasks)
            }
        } catch {
            onUpdate?([])
        }
    }
}

final class FolderFetchController: NSObject, NSFetchedResultsControllerDelegate {
    var onUpdate: (([Folder]) -> Void)?

    private let context: NSManagedObjectContext
    private var controller: NSFetchedResultsController<FolderEntity>?

    init(context: NSManagedObjectContext = CoreDataProvider.shared.persistentContainer.viewContext) {
        self.context = context
        super.init()
        configureController()
    }

    func start() {
        performFetch()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let entities = controller.fetchedObjects as? [FolderEntity] else { return }
        let folders = entities.map { Folder(from: $0) }
        onUpdate?(folders)
    }

    private func configureController() {
        let request: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.controller = controller
    }

    private func performFetch() {
        do {
            try controller?.performFetch()
            if let entities = controller?.fetchedObjects {
                onUpdate?(entities.map { Folder(from: $0) })
            }
        } catch {
            onUpdate?([])
        }
    }
}
