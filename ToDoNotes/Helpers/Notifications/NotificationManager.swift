//
//  NotificationManager.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/14/26.
//

import Foundation
import UserNotifications
import OSLog
import CoreData

private let logger = Logger(subsystem: "com.todonotes.notifications", category: "NotificationManager")

enum NotificationConstants {
    static let taskCategory = "task_reminder"
    static let taskCategoryNoComplete = "task_reminder_no_complete"
    static let actionComplete = "task_complete"
    static let actionSnooze10 = "task_snooze_10"
    static let identifierPrefix = "task."

    static let userInfoTaskId = "taskId"
    static let userInfoNotificationId = "notificationId"
}

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private var isReadyForUI = false
    private var pendingTaskId: UUID?

    private override init() {
        super.init()
    }

    func configure() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        registerCategories()
    }

    func registerCategories() {
        let complete = UNNotificationAction(
            identifier: NotificationConstants.actionComplete,
            title: Texts.TaskManagement.NotificationActions.complete,
            options: [.authenticationRequired]
        )
        let snooze = UNNotificationAction(
            identifier: NotificationConstants.actionSnooze10,
            title: Texts.TaskManagement.NotificationActions.snooze10,
            options: []
        )
        let category = UNNotificationCategory(
            identifier: NotificationConstants.taskCategory,
            actions: [complete, snooze],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        let categoryNoComplete = UNNotificationCategory(
            identifier: NotificationConstants.taskCategoryNoComplete,
            actions: [snooze],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category, categoryNoComplete])
    }

    func refreshAuthorizationStatus(completion: @escaping (NotificationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let resolved = self.resolveStatus(from: settings.authorizationStatus)
            self.persistStatus(resolved)
            DispatchQueue.main.async {
                completion(resolved)
            }
        }
    }

    func requestAuthorization(completion: @escaping (Bool, NotificationStatus) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                logger.error("Notification authorization error: \(error.localizedDescription)")
            }
            self.refreshAuthorizationStatus { status in
                DispatchQueue.main.async {
                    completion(granted, status)
                }
            }
        }
    }

    func removeAllTaskNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter {
                    $0.identifier.hasPrefix(NotificationConstants.identifierPrefix)
                    || $0.content.categoryIdentifier == NotificationConstants.taskCategory
                    || $0.content.categoryIdentifier == NotificationConstants.taskCategoryNoComplete
                }
                .map { $0.identifier }
            if !ids.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: ids)
            }
        }
        center.getDeliveredNotifications { notifications in
            let ids = notifications
                .filter {
                    $0.request.identifier.hasPrefix(NotificationConstants.identifierPrefix)
                    || $0.request.content.categoryIdentifier == NotificationConstants.taskCategory
                    || $0.request.content.categoryIdentifier == NotificationConstants.taskCategoryNoComplete
                }
                .map { $0.request.identifier }
            if !ids.isEmpty {
                center.removeDeliveredNotifications(withIdentifiers: ids)
            }
        }
    }

    func markReadyForUI() {
        isReadyForUI = true
        if let taskId = pendingTaskId {
            pendingTaskId = nil
            postSelection(taskId: taskId)
        }
    }

    func identifier(for notificationId: UUID) -> String {
        NotificationConstants.identifierPrefix + notificationId.uuidString
    }

    func userInfo(taskId: UUID, notificationId: UUID) -> [AnyHashable: Any] {
        [
            NotificationConstants.userInfoTaskId: taskId.uuidString,
            NotificationConstants.userInfoNotificationId: notificationId.uuidString
        ]
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .badge]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotificationResponse(response)
        completionHandler()
    }

    private func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        guard let taskIdString = userInfo[NotificationConstants.userInfoTaskId] as? String,
              let taskId = UUID(uuidString: taskIdString)
        else {
            return
        }

        switch response.actionIdentifier {
        case NotificationConstants.actionComplete:
            handleCompleteAction(taskId: taskId)
        case NotificationConstants.actionSnooze10:
            if let notificationIdString = userInfo[NotificationConstants.userInfoNotificationId] as? String,
               let notificationId = UUID(uuidString: notificationIdString) {
                handleSnoozeAction(taskId: taskId, notificationId: notificationId, minutes: 10)
            }
        case UNNotificationDefaultActionIdentifier:
            deliverSelection(taskId: taskId)
        default:
            break
        }
    }

    private func deliverSelection(taskId: UUID) {
        if isReadyForUI {
            postSelection(taskId: taskId)
        } else {
            pendingTaskId = taskId
        }
    }

    private func postSelection(taskId: UUID) {
        NotificationCenter.default.post(
            name: .didSelectTaskFromNotification,
            object: nil,
            userInfo: [NotificationConstants.userInfoTaskId: taskId]
        )
    }

    private func handleCompleteAction(taskId: UUID) {
        guard let task = fetchTask(id: taskId) else { return }
        do {
            try TaskService.toggleCompleteChecking(for: task)
        } catch {
            logger.error("Failed to complete task from notification: \(error.localizedDescription)")
        }
    }

    private func handleSnoozeAction(taskId: UUID, notificationId: UUID, minutes: Int) {
        guard let task = fetchTask(id: taskId),
              let notification = fetchNotification(id: notificationId)
        else { return }

        let newDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        notification.target = newDate
        notification.updatedAt = .now

        if let context = notification.managedObjectContext {
            context.perform {
                do {
                    try context.save()
                } catch {
                    logger.error("Failed to save snoozed notification: \(error.localizedDescription)")
                }
            }
        }

        UNUserNotificationCenter.current().setupNotification(
            for: notification,
            taskId: task.id,
            with: task.name,
            titleOverride: Texts.TaskManagement.NotificationActions.snoozed10Title
        )
    }

    private func fetchTask(id: UUID) -> TaskEntity? {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func fetchNotification(id: UUID) -> NotificationEntity? {
        let context = CoreDataProvider.shared.persistentContainer.viewContext
        let request: NSFetchRequest<NotificationEntity> = NotificationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private func resolveStatus(from systemStatus: UNAuthorizationStatus) -> NotificationStatus {
        switch systemStatus {
        case .authorized, .provisional, .ephemeral:
            let current = NotificationStatus.current
            return current == .disabled ? .disabled : .allowed
        case .denied:
            return .prohibited
        case .notDetermined:
            return .prohibited
        @unknown default:
            return .prohibited
        }
    }

    private func persistStatus(_ status: NotificationStatus) {
        UserDefaults.standard.set(status.rawValue, forKey: Texts.UserDefaults.notifications)
    }
}

extension NotificationStatus {
    static var current: NotificationStatus {
        let rawValue = UserDefaults.standard.string(forKey: Texts.UserDefaults.notifications) ?? String()
        return NotificationStatus(rawValue: rawValue) ?? .prohibited
    }
}

extension Notification.Name {
    static let didSelectTaskFromNotification = Notification.Name("didSelectTaskFromNotification")
}
