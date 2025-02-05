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
        removeNotifications(for: entityNotifications)
        
        for notification in notifications {
            guard let targetDate = notification.target else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = notification.type.notificationName
            content.body = name ?? String()
            content.sound = .default
            
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)
            
            self.add(request) { error in
                if let error = error {
                    print("Notification setup error: \(error.localizedDescription)")
                } else {
                    print("Notification successfully setup for \(String(describing: name)) at \(targetDate) with type \(notification.type.selectorName)")
                }
            }
        }
    }
    
    internal func removeNotifications(for items: Set<NotificationItem>) {
        let identifiers = items.map { $0.id.uuidString }
        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)
        print("Remove notifications success")
    }
    
    internal func removeNotifications(for items: NSSet?) {
        guard let notifications = items?.compactMap({ $0 as? NotificationEntity }) else {
            print("Remove notifications error: items must be Set<NotificationEntity>")
            return
        }
        let identifiers = notifications.map({ $0.id?.uuidString ?? String() })
        
        guard !identifiers.isEmpty else {
            print("No valid notification IDs found for removal")
            return
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        
        print("Removed notifications: \(identifiers)")
    }
}
