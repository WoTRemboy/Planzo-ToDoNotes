//
//  UserNotificationCenterExtension.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/3/25.
//

import UserNotifications
import OSLog

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
                                     with name: String?) {
        // First removes any existing notifications
        removeNotifications(for: entityNotifications)
        
        // Gets current pending notifications to check for duplicates
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { pendingRequests in
            let existingIdentifiers = Set(pendingRequests.map { $0.identifier })
            
            for notification in notifications {
                guard let targetDate = notification.target,
                      targetDate > Date() else { continue }
                
                let identifier = notification.id.uuidString
                
                // Skips if notification with this ID already exists
                guard !existingIdentifiers.contains(identifier) else {
                    logger.debug("Skipping duplicate notification with ID: \(identifier)")
                    continue
                }
                
                let content = UNMutableNotificationContent()
                content.title = notification.type.notificationName
                content.body = name ?? String()
                content.sound = .default
                
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
    
    // MARK: - Notification Removal
    
    /// Removes notifications for the given set of `NotificationItem`s.
    /// - Parameter items: A set of `NotificationItem` instances whose notifications should be removed.
    internal func removeNotifications(for items: Set<NotificationItem>) {
        let identifiers = items.map { $0.id.uuidString }
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
        
        let identifiers = notifications.compactMap { $0.id?.uuidString }
        
        guard !identifiers.isEmpty else {
            logger.debug("No valid notification IDs found for removal")
            return
        }
        
        // Remove both pending and delivered notifications
        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)
        
        logger.debug("Removed notifications with IDs: \(identifiers)")
    }
}
