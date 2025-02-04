//
//  UserNotificationCenterExtension.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/3/25.
//

import UserNotifications

extension UNUserNotificationCenter {
    internal func setupNotifications(for notifications: Set<NotificationItem>,
                                     with name: String?) {
        guard !notifications.isEmpty,
              let name = name
        else {
            print("Notification setup error: params are not valid")
            return
        }
        
        for notification in notifications {
            guard let targetDate = notification.target else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = notification.type.notificationName
            content.body = name
            content.sound = .default
            
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: targetDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)
            
            self.add(request) { error in
                if let error = error {
                    print("Notification setup error: \(error.localizedDescription)")
                } else {
                    print("Notification successfully setup for \(name) at \(targetDate) with type \(notification.type.selectorName)")
                }
            }
        }
    }
    
    internal func removeNotifications(for items: Set<NotificationItem>) {
        let identifiers = items.map { $0.id.uuidString }
        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}
