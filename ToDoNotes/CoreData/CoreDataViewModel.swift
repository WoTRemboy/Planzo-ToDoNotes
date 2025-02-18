//
//  CoreDataViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/12/25.
//

import Foundation
import Combine
import CoreData
import UserNotifications

final class CoreDataViewModel: ObservableObject {
    
    @Published internal var savedEnities: [TaskEntity] = []
    @Published internal var segmentedAndSortedTasksArray: [(Date?, [TaskEntity])] = []
    @Published internal var segmentedAndSortedTasksDict: [Date?: [TaskEntity]] = [:]
    private let container: NSPersistentContainer
    
    internal var isEmpty : Bool {
        savedEnities.isEmpty
    }
    
    internal var daysWithTasks: Set<Date> {
        var result = Set<Date>()
        
        for date in segmentedAndSortedTasksDict {
            let day = date.0 ?? Date()
            result.insert(day)
        }
        return result
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
    
    internal func addTask(name: String,
                          description: String,
                          completeCheck: TaskCheck,
                          target: Date?,
                          hasTime: Bool,
                          notifications: Set<NotificationItem>) {
        let newTask = TaskEntity(context: container.viewContext)
        
        newTask.id = UUID()
        newTask.name = name
        newTask.details = description
        newTask.completed = completeCheck.rawValue
        newTask.created = .now
        newTask.target = target
        newTask.hasTargetTime = hasTime
        
        var notificationEntities = [NotificationEntity]()
        for item in notifications {
            let entityItem = NotificationEntity(context: container.viewContext)
            entityItem.id = item.id
            entityItem.type = item.type.rawValue
            entityItem.target = item.target
            notificationEntities.append(entityItem)
        }
        let notificationsSet = NSSet(array: notificationEntities)
        newTask.notifications = notificationsSet
        
        saveData()
    }
    
    internal func updateTask(entity: TaskEntity,
                             name: String,
                             description: String,
                             completeCheck: TaskCheck,
                             target: Date?,
                             hasTime: Bool,
                             notifications: Set<NotificationItem> = [],
                             checklist: [ChecklistItem] = []) {
        entity.name = name
        entity.details = description
        entity.completed = completeCheck.rawValue
        entity.target = target
        entity.hasTargetTime = hasTime
        
        var notificationEntities = [NotificationEntity]()
        for item in notifications {
            let entityItem = NotificationEntity(context: container.viewContext)
            entityItem.id = item.id
            entityItem.type = item.type.rawValue
            entityItem.target = item.target
            notificationEntities.append(entityItem)
        }
        let notificationsSet = NSSet(array: notificationEntities)
        entity.notifications = notificationsSet
        
        var checklistEnities = [ChecklistEntity]()
        for item in checklist {
            let entityItem = ChecklistEntity(context: container.viewContext)
            entityItem.name = item.name
            entityItem.completed = item.completed
            checklistEnities.append(entityItem)
        }
        let orderedChecklist = NSOrderedSet(array: checklistEnities)
        entity.checklist = orderedChecklist
        
        saveData()
    }
    
    private func deleteTask(indexSet: IndexSet) {
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
            setupSegmentedAndSortedTasks()
        } catch let error {
            print("Error fetching tasks: \(error.localizedDescription)")
        }
    }
    
    private func setupSegmentedAndSortedTasks() {
        var groupedTasks: [Date: [TaskEntity]] = [:]
        
        for task in savedEnities {
            let referenceDate = task.target ?? task.created ?? Date.distantPast
            let day = Calendar.current.startOfDay(for: referenceDate)
            groupedTasks[day, default: []].append(task)
        }
        
        segmentedAndSortedTasksDict = groupedTasks
        sortSegmentedAndSortedTasksDict()
        
        segmentedAndSortedTasksArray = groupedTasks
            .map { (day, tasks) in
                let sortedTasks = tasks.sorted { t1, t2 in
                    let d1 = (t1.target != nil && t1.hasTargetTime) ? t1.target! : Date.distantFuture
                    let d2 = (t2.target != nil && t2.hasTargetTime) ? t2.target! : Date.distantFuture
                    return d1 < d2
                }
                return (day, sortedTasks)
            }
            .sorted { $0.0 ?? Date.distantFuture > $1.0 ?? Date.distantFuture }
    }
    
    internal func filteredSegmentedTasks(for filter: Filter) -> [(Date?, [TaskEntity])] {
        let now = Date()
        return segmentedAndSortedTasksArray.compactMap { (date, tasks) in
            let filteredTasks = tasks.filter { task in
                switch filter {
                case .active:
                    guard task.completed != 2 else { return false }
                    if let target = task.target, target < (task.hasTargetTime ? now : now.startOfDay) {
                        return false
                    } else if task.target == nil, let created = task.created, created < now.startOfDay {
                        return false
                    }
                    return true
                case .outdated:
                    if task.completed == 1,
                       let target = task.target,
                       task.hasTargetTime,
                       target < now {
                        return true
                    }
                    return false
                case .completed:
                    return task.completed == 2
                case .unsorted:
                    return true
                }
            }
            return filteredTasks.isEmpty ? nil : (date, filteredTasks)
        }
    }
    
    internal func deleteTasks(with ids: [NSManagedObjectID]) {
        ids.forEach { id in
            if let object = try? container.viewContext.existingObject(with: id) as? TaskEntity {
                UNUserNotificationCenter.current().removeNotifications(for: object.notifications)
                container.viewContext.delete(object)
            }
        }
        saveData()
    }
    
    internal func deleteAllTasksAndClearNotifications(completion: ((Bool) -> Void)? = nil) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Texts.CoreData.entity)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            if let result = try container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
               let objectIDs = result.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
            }
            container.viewContext.reset()
            
            fetchTasks()
            completion?(true)
        } catch {
            print("Batch delete error: \(error.localizedDescription)")
            completion?(false)
        }
    }
}


extension CoreDataViewModel {
    
    internal func dayTasks(for date: Date) -> [TaskEntity] {
        let day = Calendar.current.startOfDay(for: date)
        return segmentedAndSortedTasksDict[day] ?? []
    }
    
    internal func haveTextContent(for entity: TaskEntity) -> Bool {
        let details = entity.details ?? String()
        
        let firstChecklistElement = entity.checklist?.compactMap({ $0 as? ChecklistEntity }).first
        let firstChecklistName = firstChecklistElement?.name ?? String()
        let checklistCount = entity.checklist?.count ?? 0

        return !details.isEmpty || (!firstChecklistName.isEmpty || checklistCount > 1)
    }
    
    private func sortSegmentedAndSortedTasksDict() {
        for (day, tasks) in segmentedAndSortedTasksDict {
            let sortedTasks = tasks.sorted { t1, t2 in
                let d1 = (t1.target != nil && t1.hasTargetTime) ? t1.target! : Date.distantFuture
                let d2 = (t2.target != nil && t2.hasTargetTime) ? t2.target! : Date.distantFuture
                return d1 < d2
            }
            segmentedAndSortedTasksDict[day] = sortedTasks
        }
    }
    
    internal func setupChecking(for entity: TaskEntity) {
        if entity.completed == 0 {
            entity.completed = 1
        } else {
            entity.completed = 0
        }
        saveData()
    }
    
    private func showCheckStatus(for entity: TaskEntity) -> Int16 {
        entity.completed == 2 ? 2 : 1
    }
    
    internal func checkCompletedStatus(for entity: TaskEntity) -> Bool {
        entity.completed == 1
    }
    
    internal func taskCheckStatus(for entity: TaskEntity) -> Bool {
        entity.completed == 2
    }
    
    internal func toggleCompleteChecking(for entity: TaskEntity) {
        entity.completed = entity.completed == 1 ? 2 : 1
        saveData()
    }
    
    private func notificationName(for type: String) -> String {
        let notificationType = TaskNotification(rawValue: type) ?? .inTime
        
        switch notificationType {
        case .none:
            return String()
        case .inTime:
            return Texts.TaskManagement.DatePicker.inTimeNotification
        case .fiveMinutesBefore:
            return Texts.TaskManagement.DatePicker.fiveMinutesBeforeNotification
        case .thirtyMinutesBefore:
            return Texts.TaskManagement.DatePicker.thirtyMinutesBeforeNotification
        case .oneHourBefore:
            return Texts.TaskManagement.DatePicker.oneHourBeforeNotification
        case .oneDayBefore:
            return Texts.TaskManagement.DatePicker.oneDayBeforeNotification
        }
    }
}


extension CoreDataViewModel {
    internal func restoreNotificationsForAllTasks(completion: ((Bool) -> Void)? = nil) {
        // Create a fetch request for tasks that have at least one notification.
        let request: NSFetchRequest<TaskEntity> = NSFetchRequest(entityName: Texts.CoreData.entity)
        request.predicate = NSPredicate(format: "notifications.@count > 0")
        
        do {
            // Fetch tasks with notifications from Core Data.
            let tasksWithNotifications = try container.viewContext.fetch(request)
            let group = DispatchGroup()
            let notificationCenter = UNUserNotificationCenter.current()
            
            // Iterate over each task
            for task in tasksWithNotifications {
                if let notificationsSet = task.notifications as? Set<NotificationEntity> {
                    for entity in notificationsSet {
                        // Ensure the target date exists and is in the future
                        guard let targetDate = entity.target, targetDate > Date() else { continue }
                        
                        // Convert the ObjectIdentifier (or similar type) to a String
                        let identifier = entity.id?.uuidString ?? String()
                        
                        // Create the notification content
                        let content = UNMutableNotificationContent()
                        content.title = notificationName(for: entity.type ?? TaskNotification.inTime.rawValue)
                        content.body = task.name ?? String()
                        content.sound = .default
                        
                        // Create date components from the target date
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                        
                        // Create the notification request
                        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                        
                        group.enter()
                        notificationCenter.add(request) { error in
                            if let error = error {
                                print("Error scheduling notification with id \(identifier): \(error.localizedDescription)")
                            }
                            group.leave()
                        }
                    }
                }
            }
            
            // Call the completion handler once all notifications are scheduled.
            group.notify(queue: .main) {
                completion?(true)
            }
        } catch {
            print("Error fetching tasks for restoring notifications: \(error.localizedDescription)")
            completion?(false)
        }
    }
}
