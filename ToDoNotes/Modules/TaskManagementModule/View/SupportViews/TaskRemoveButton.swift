//
//  TaskRemoveButton.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/12/25.
//

import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.todonotes.shared", category: "TaskRemoveButton")

struct TaskRemoveButton: View {
    
    @ObservedObject private var entity: TaskEntity
    
    private let isInDeletedContext: () -> Bool
    private let requestConfirmSharedDelete: ((TaskEntity) -> Void)?
    
    @State private var isDeleting: Bool = false
    
    init(entity: TaskEntity,
         isInDeletedContext: @escaping () -> Bool,
         requestConfirmSharedDelete: ((TaskEntity) -> Void)? = nil) {
        self._entity = ObservedObject(wrappedValue: entity)
        self.isInDeletedContext = isInDeletedContext
        self.requestConfirmSharedDelete = requestConfirmSharedDelete
    }
    
    internal var body: some View {
        Button(role: (entity.role == nil || entity.role == ShareAccess.owner.rawValue) ? .destructive : .cancel) {
            handleRemoveTap()
        } label: {
            Image.TaskManagement.TaskRow.SwipeAction.remove
        }
        .tint(Color.SwipeColors.remove)
        .disabled(isDeleting)
    }
    
    private func handleRemoveTap() {
        guard !isDeleting else { return }
        
        if let role = entity.role, role != ShareAccess.owner.rawValue {
            if let confirm = requestConfirmSharedDelete {
                confirm(entity)
            } else {
                try? TaskService.toggleRemoved(for: entity)
            }
            return
        }
        
        isDeleting = true
        withAnimation(.easeInOut(duration: 0.2)) {
            do {
                if isInDeletedContext() {
                    try TaskService.deleteRemovedTask(for: entity)
                    logger.debug("Task permanently deleted.")
                    Toast.shared.present(title: Texts.Toasts.deleted)
                } else {
                    try TaskService.toggleRemoved(for: entity)
                    logger.debug("Task moved to trash: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                    Toast.shared.present(title: Texts.Toasts.removed)
                }
            } catch {
                logger.error("Task remove action failed: \(error.localizedDescription)")
            }
        }
        isDeleting = false
    }
}

