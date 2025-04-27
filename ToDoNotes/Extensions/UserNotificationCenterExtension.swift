//
//  UserNotificationCenterExtension.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/3/25.
//

import UserNotifications

extension UNUserNotificationCenter {
    internal func setupNotifications(for notifications: Set<NotificationItem>,
                                     remove entityNotifications: NSSet?,
                                     with name: String?) {
        // First remove any existing notifications
        removeNotifications(for: entityNotifications)
        
        // Get current pending notifications to check for duplicates
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { pendingRequests in
            let existingIdentifiers = Set(pendingRequests.map { $0.identifier })
            
            for notification in notifications {
                guard let targetDate = notification.target,
                      targetDate > Date() else { continue }
                
                let identifier = notification.id.uuidString
                
                // Skip if notification with this ID already exists
                guard !existingIdentifiers.contains(identifier) else {
                    print("Skipping duplicate notification with ID: \(identifier)")
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
                        print("Notification setup error for \(identifier): \(error.localizedDescription)")
                    } else {
                        print("Notification successfully setup for \(String(describing: name)) at \(targetDate) with type \(notification.type.selectorName)")
                    }
                }
            }
        }
    }
    
    internal func removeNotifications(for items: Set<NotificationItem>) {
        let identifiers = items.map { $0.id.uuidString }
        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)
        print("Removed notifications with IDs: \(identifiers)")
    }
    
    internal func removeNotifications(for items: NSSet?) {
        guard let notifications = items?.compactMap({ $0 as? NotificationEntity }) else {
            print("Remove notifications error: items must be Set<NotificationEntity>")
            return
        }
        
        let identifiers = notifications.compactMap { $0.id?.uuidString }
        
        guard !identifiers.isEmpty else {
            print("No valid notification IDs found for removal")
            return
        }
        
        // Remove both pending and delivered notifications
        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)
        
        print("Removed notifications with IDs: \(identifiers)")
    }
}
