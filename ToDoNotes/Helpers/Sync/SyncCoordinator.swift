//
//  SyncCoordinator.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 03/12/2025.
//

import Foundation

final class SyncCoordinator {
    static let shared = SyncCoordinator()

    private let queue = DispatchQueue(label: "com.todonotes.sync-coordinator")
    private var inFlight = Set<String>()
    private var lastPushedAtByKey: [String: Date] = [:]
    private var isLocalSyncRunning = false

    func beginLocalSyncIfPossible() -> Bool {
        queue.sync {
            if isLocalSyncRunning { return false }
            isLocalSyncRunning = true
            return true
        }
    }

    func endLocalSync() {
        queue.async {
            self.isLocalSyncRunning = false
        }
    }

    func shouldStartTask(for key: String, updatedAt: Date) -> Bool {
        queue.sync {
            if inFlight.contains(key) { return false }
            if let lastPushed = lastPushedAtByKey[key], updatedAt <= lastPushed {
                return false
            }
            inFlight.insert(key)
            return true
        }
    }

    func finishTask(for key: String, pushedAt: Date, success: Bool) {
        queue.async {
            self.inFlight.remove(key)
            if success {
                self.lastPushedAtByKey[key] = pushedAt
            }
        }
    }
}
