//
//  MainTaskRowWithActions.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/9/25.
//

import SwiftUI
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.main", category: "MainTaskRowWithActions")

/// Displays a single task row with support for swipe actions (important, pinned, restore, delete).
struct MainTaskRowWithActions: View {
        
    @EnvironmentObject private var viewModel: MainViewModel
    @EnvironmentObject private var authService: AuthNetworkService
    
    /// The task entity displayed in the row.
    @ObservedObject private var entity: TaskEntity
    /// Indicates if the task is the last in its section (for divider behavior).
    private let isLast: Bool
    private let onShowFolderSetup: ((TaskEntity) -> Void)?
    
    init(entity: TaskEntity, isLast: Bool, onShowFolderSetup: ((TaskEntity) -> Void)? = nil) {
        self._entity = ObservedObject(wrappedValue: entity)
        self.isLast = isLast
        self.onShowFolderSetup = onShowFolderSetup
    }
    
    // MARK: - Body
    
    internal var body: some View {
        Button {
            handleRowTap()
        } label: {
            TaskListRow(entity: entity, isLast: isLast)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: viewModel.selectedFilter == .deleted) {
            leadingSwipeActions
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            trailingSwipeAction
        }
    }
    
    // MARK: - Actions
    
    /// Handles tapping the task row depending on the selected filter.
    private func handleRowTap() {
        if viewModel.selectedFilter == .deleted {
            viewModel.removedTask = entity
            viewModel.toggleShowingEditRemovedAlert()
            logger.debug("Tapped on a deleted task to recover: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
        } else {
            viewModel.selectedTask = entity
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            logger.debug("Tapped on an active task to edit: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
        }
    }
    
    /// Defines leading swipe actions for the task (important, pin, or restore).
    @ViewBuilder
    private var leadingSwipeActions: some View {
        if viewModel.selectedFilter != .deleted {
            importantButton
            pinnedButton
        } else {
            restoreButton
        }
    }
    
    /// Defines trailing swipe action for sharing, moving and deleting the task.
    @ViewBuilder
    private var trailingSwipeAction: some View {
        removeButton
        if viewModel.selectedFilter != .deleted {
            folderButton
            if authService.isAuthorized {
                shareButton
            }
        }
    }
    
    // MARK: - Swipe Action Buttons
    
    /// Button to mark task as important or remove importance.
    private var importantButton: some View {
        Button(role: viewModel.importance ? .destructive : .cancel) {
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.toggleImportant(for: entity)
                    logger.debug("Toggled important status to \(entity.important) for task: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Toggle important status for task failed: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                }
            }
            Toast.shared.present(
                title: entity.important ? Texts.Toasts.importantOn : Texts.Toasts.importantOff
            )
        } label: {
            TaskService.taskCheckImportant(for: entity) ?
            Image.TaskManagement.TaskRow.SwipeAction.importantDeselect :
            Image.TaskManagement.TaskRow.SwipeAction.important
        }
        .tint(Color.SwipeColors.important)
    }
    
    /// Button to pin or unpin the task.
    private var pinnedButton: some View {
        Button(role: .cancel) {
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.togglePinned(for: entity)
                    logger.debug("Toggled pinned status to \(entity.pinned) for task: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Toggle pinned status for task failed: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                }
            }
            Toast.shared.present(
                title: entity.pinned ? Texts.Toasts.pinnedOn : Texts.Toasts.pinnedOff
            )
        } label: {
            TaskService.taskCheckPinned(for: entity) ?
            Image.TaskManagement.TaskRow.SwipeAction.pinnedDeselect :
            Image.TaskManagement.TaskRow.SwipeAction.pinned
        }
        .tint(Color.SwipeColors.pin)
    }
    
    /// Button to restore a deleted task.
    private var restoreButton: some View {
        Button(role: .destructive) {
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.toggleRemoved(for: entity)
                    logger.debug("Restored task from deleted: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Restore task failed: \(error.localizedDescription)")
                }
            }
        } label: {
            Image.TaskManagement.TaskRow.SwipeAction.restore
        }
        .tint(Color.SwipeColors.restore)
    }
    
    private var shareButton: some View {
        Button {
            viewModel.setSharingTask(to: entity)
        } label: {
            Image.TaskManagement.TaskRow.SwipeAction.share
        }
        .tint(Color.SwipeColors.share)
    }
    
    private var folderButton: some View {
        Button {
            onShowFolderSetup?(entity) ?? viewModel.toggleShowingFolderSetupView()
        } label: {
            Image.TaskManagement.TaskRow.SwipeAction.folder
        }
        .tint(Color.SwipeColors.folder)
    }
    
    private var removeButton: some View {
        Button(role: .destructive) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if viewModel.selectedFilter != .deleted {
                    do {
                        try TaskService.toggleRemoved(for: entity)
                        Toast.shared.present(title: Texts.Toasts.removed)
                        logger.debug("Task moved to deleted: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                    } catch {
                        logger.error("Task could not be moved to deleted: \(error.localizedDescription)")
                    }
                } else {
                    do {
                        try TaskService.deleteRemovedTask(for: entity)
                        logger.debug("Task permanently deleted.")
                    } catch {
                        logger.error("Task could not be permanently deleted: \(error.localizedDescription)")
                    }
                }
            }
        } label: {
            Image.TaskManagement.TaskRow.SwipeAction.remove
        }
        .tint(Color.SwipeColors.remove)
    }
}

// MARK: - Preview

#Preview {
    MainTaskRowWithActions(entity: TaskEntity(), isLast: false)
        .environmentObject(MainViewModel())
        .environmentObject(AuthNetworkService())
}

