//
//  UserNotificationCenterExtension.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/3/25.
//

import UserNotifications
import OSLog
import CoreData

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.extensions", category: "UserNotificationCenterExtension")

extension UNUserNotificationCenter {
    
    // MARK: - Notification Setup
    
    /// Sets up notifications for the given set of `NotificationItem`s.
    /// - Parameters:
    ///   - notifications: A set of `NotificationItem` instances to schedule notifications for.
    ///   - entityNotifications: An optional `NSSet` of existing notifications to remove before scheduling new ones.
    ///   - name: An optional string to be used as the notification body.
    internal func setupNotifications(for notifications: Set<NotificationItem>,
                                     remove entityNotifications: NSSet?,
                                     taskId: UUID?,
                                     with name: String?) {
        // First removes any existing notifications
        removeNotifications(for: entityNotifications)
        
        let defaults = UserDefaults.standard
        let rawValue = defaults.string(forKey: Texts.UserDefaults.notifications) ?? String()
        let notificationsStatus = NotificationStatus(rawValue: rawValue) ?? .prohibited
        guard notificationsStatus == .allowed else { return }
        
        // Gets current pending notifications to check for duplicates
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { pendingRequests in
            let existingIdentifiers = Set(pendingRequests.map { $0.identifier })
            let categoryId = self.categoryIdentifier(for: taskId)
            
            for notification in notifications {
                guard let targetDate = notification.target,
                      targetDate > Date() else { continue }

                let identifier = NotificationManager.shared.identifier(for: notification.id)

                // Skips if notification with this ID already exists
                guard !existingIdentifiers.contains(identifier) else {
                    logger.debug("Skipping duplicate notification with ID: \(identifier)")
                    continue
                }

                let content = UNMutableNotificationContent()
                content.title = notification.type.notificationName
                content.body = name ?? Texts.TaskManagement.TaskRow.placeholder
                content.sound = .default
                content.categoryIdentifier = categoryId
                if let taskId {
                    content.userInfo = NotificationManager.shared.userInfo(taskId: taskId, notificationId: notification.id)
                }

                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                self.add(request) { error in
                    if let error = error {
                        logger.error("Notification setup error for \(identifier): \(error.localizedDescription)")
                    } else {
                        logger.debug("Notification successfully setup for \(String(describing: name)) at \(targetDate) with type \(notification.type.selectorName)")
                    }
                }
            }
        }
    }
    
    /// Schedules a single notification for the given NotificationItem.
    /// - Parameters:
    ///   - notification: The NotificationItem to schedule.
    ///   - name: The name (body) to display in the notification.
    internal func setupNotification(for notification: NotificationEntity, taskId: UUID?, with name: String?, titleOverride: String? = nil) {
        
        let defaults = UserDefaults.standard
        let rawValue = defaults.string(forKey: Texts.UserDefaults.notifications) ?? String()
        let notificationsStatus = NotificationStatus(rawValue: rawValue) ?? .prohibited
        guard notificationsStatus == .allowed else { return }
        
        guard let targetDate = notification.target,
              targetDate > Date(),
              let notificationId = notification.id,
              let type = notification.type
        else { return }

        let identifier = NotificationManager.shared.identifier(for: notificationId)

        let content = UNMutableNotificationContent()
        content.title = titleOverride ?? TaskNotification(rawValue: type)?.notificationName ?? type
        content.body = name ?? Texts.TaskManagement.TaskRow.placeholder
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier(for: taskId, task: notification.task)
        if let taskId {
            content.userInfo = NotificationManager.shared.userInfo(taskId: taskId, notificationId: notificationId)
        }
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        self.add(request) { error in
            if let error = error {
                logger.error("Notification setup error for \(identifier): \(error.localizedDescription)")
            } else {
                logger.debug("Notification successfully setup for \(String(describing: name)) at \(targetDate) with type \(notification.type ?? "nil")")
            }
        }
    }
    
    private func categoryIdentifier(for taskId: UUID?, task: TaskEntity? = nil) -> String {
        if let completed = task?.completed {
            return completed == 0 ? NotificationConstants.taskCategoryNoComplete : NotificationConstants.taskCategory
        }
        guard let taskId else { return NotificationConstants.taskCategory }

        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", taskId as CVarArg)
        request.fetchLimit = 1
        let taskEntity = try? context.fetch(request).first
        if let completed = taskEntity?.completed, completed == 0 {
            return NotificationConstants.taskCategoryNoComplete
        }
        return NotificationConstants.taskCategory
    }

    // MARK: - Notification Removal
    
    /// Removes notifications for the given set of `NotificationItem`s.
    /// - Parameter items: A set of `NotificationItem` instances whose notifications should be removed.
    internal func removeNotifications(for items: Set<NotificationItem>) {
        let identifiers = items.map { NotificationManager.shared.identifier(for: $0.id) }
        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)
        logger.debug("Removed notifications with IDs: \(identifiers)")
    }
    
    /// Removes notifications for the given optional `NSSet` of `NotificationEntity` objects.
    /// - Parameter items: An optional `NSSet` of `NotificationEntity` objects to remove notifications for.
    internal func removeNotifications(for items: NSSet?) {
        guard let notifications = items?.compactMap({ $0 as? NotificationEntity }) else {
            logger.error("Remove notifications error: items must be Set<NotificationEntity>")
            return
        }
        
        let identifiers: [String] = notifications.compactMap { notification in
            guard let id = notification.id else { return nil }
            return NotificationManager.shared.identifier(for: id)
        }
        
        guard !identifiers.isEmpty else {
            logger.debug("No valid notification IDs found for removal")
            return
        }
        
        // Remove both pending and delivered notifications
        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)
        
        logger.debug("Removed notifications with IDs: \(identifiers)")
    }
    
    // MARK: - Notification Logging
    
    /// Logs notifications for the given optional `NSSet` of `NotificationEntity` objects.
    /// - Parameter entityNotifications: An optional `NSSet` of `NotificationEntity` objects to log notifications for.
    internal func logNotifications(for entityNotifications: NSSet?) {
        guard let notifications = entityNotifications?.compactMap({ $0 as? NotificationEntity }) else {
            logger.error("Log notifications error: items must be Set<NotificationEntity>")
            return
        }
        let identifiers = notifications.compactMap { $0.id?.uuidString }
        if identifiers.isEmpty {
            logger.debug("No notifications found for task")
        } else {
            logger.debug("Notifications for task:")
            for notification in notifications {
                logger.debug("Notification ID: \(notification.id?.uuidString ?? "nil") Date: \(notification.target?.description ?? "nil") Type: \(notification.type ?? "nil")")
            }
            logger.debug("--- End of notifications for task ---")
        }
    }
}

