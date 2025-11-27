//
//  CalendarTaskRowWithActions.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/9/25.
//

import SwiftUI
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.calendar", category: "CalendarTaskRowWithActions")

/// A view that represents a single task row inside the Calendar screen, with available swipe actions.
struct CalendarTaskRowWithActions: View {
    
    // MARK: - Properties
    
    /// Access to the CalendarViewModel to update task-related states.
    @EnvironmentObject private var viewModel: CalendarViewModel
    @EnvironmentObject private var authService: AuthNetworkService
    
    /// The task entity displayed in the row.
    @ObservedObject private var entity: TaskEntity
    /// Flag indicating whether this is the last task in the list.
    private let isLast: Bool
    /// Closure to call when folder setup should be shown, passing the current task entity.
    private let onShowFolderSetup: ((TaskEntity) -> Void)?
    
    // MARK: - Initialization
    
    /// Initializes the task row with entity and position information.
    ///
    /// - Parameters:
    ///   - entity: The task to be displayed.
    ///   - isLast: A Boolean indicating if this is the last task in the section.
    ///   - onShowFolderSetup: An optional closure to handle folder setup action with the task entity.
    init(entity: TaskEntity, isLast: Bool, onShowFolderSetup: ((TaskEntity) -> Void)? = nil) {
        self._entity = ObservedObject(wrappedValue: entity)
        self.isLast = isLast
        self.onShowFolderSetup = onShowFolderSetup
    }
    
    // MARK: - Body
    
    internal var body: some View {
        Button {
            // Selecting the task for editing.
            viewModel.selectedTask = entity
            logger.debug("Tapped on a task to edit: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
        } label: {
            TaskListRow(entity: entity, isLast: isLast)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if entity.role != ShareAccess.viewOnly.rawValue {
                leadingSwipeActions
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            trailingSwipeAction
        }
    }
    
    // MARK: - Leading Swipe Actions
    
    /// Actions shown when swiping from left to right.
    @ViewBuilder
    private var leadingSwipeActions: some View {
        toggleImportantButton
        togglePinnedButton
    }
    
    /// Button to toggle important status.
    private var toggleImportantButton: some View {
        Button(role: .cancel) {
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.toggleImportant(for: entity)
                    Toast.shared.present(
                        title: entity.important
                        ? Texts.Toasts.importantOn
                        : Texts.Toasts.importantOff
                    )
                    logger.debug("Toggled important status to \(entity.important) for \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Failed to toggle important for \(entity.name ?? "unnamed") \(error.localizedDescription)")
                }
            }
        } label: {
            TaskService.taskCheckImportant(for: entity)
            ? Image.TaskManagement.TaskRow.SwipeAction.importantDeselect
            : Image.TaskManagement.TaskRow.SwipeAction.important
        }
        .tint(Color.SwipeColors.important)
    }
    
    /// Button to toggle pinned status.
    private var togglePinnedButton: some View {
        Button(role: .destructive) {
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.togglePinned(for: entity)
                    Toast.shared.present(
                        title: entity.pinned
                        ? Texts.Toasts.pinnedOn
                        : Texts.Toasts.pinnedOff
                    )
                    logger.debug("Toggled pinned status to \(entity.important) for \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Failed to toggle pin for \(entity.name ?? "unnamed") \(error.localizedDescription)")
                }
            }
        } label: {
            TaskService.taskCheckPinned(for: entity)
            ? Image.TaskManagement.TaskRow.SwipeAction.pinnedDeselect
            : Image.TaskManagement.TaskRow.SwipeAction.pinned
        }
        .tint(Color.SwipeColors.pin)
    }
    
    // MARK: - Trailing Swipe Action
    
    /// Action shown when swiping from right to left.
    @ViewBuilder
    private var trailingSwipeAction: some View {
        removeButton
        if entity.members == 0 {
            folderButton
        }
        
        if authService.isAuthorized, (entity.role == ShareAccess.owner.rawValue || entity.role == nil) {
            shareButton
        }
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
                do {
                    try TaskService.toggleRemoved(for: entity)
                    Toast.shared.present(title: Texts.Toasts.removed)
                    logger.debug("Task removed: \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Failed to remove task: \(entity.name ?? "unnamed") \(error.localizedDescription)")
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
    CalendarTaskRowWithActions(entity: PreviewData.taskItem, isLast: false, onShowFolderSetup: nil)
        .environmentObject(AuthNetworkService())
}
