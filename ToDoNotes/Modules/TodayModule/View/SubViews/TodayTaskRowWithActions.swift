//
//  TodayTaskRowWithActions.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/9/25.
//

import SwiftUI
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.today", category: "TodayTaskRowWithActions")

/// A task row view for Today page with leading and trailing swipe actions.
/// Allows marking task as important, pinning, and removing tasks.
struct TodayTaskRowWithSwipeActions: View {
    
    // MARK: - Properties
    
    /// View model managing Today page state.
    @EnvironmentObject private var viewModel: TodayViewModel
    
    /// The task entity being displayed.
    @ObservedObject private var entity: TaskEntity
    
    /// Whether this row is the last in the list.
    private let isLast: Bool
    /// Namespace for matched geometry animations.
    private let namespace: Namespace.ID
    /// Optional closure called when folder setup is requested.
    private let onShowFolderSetup: ((TaskEntity) -> Void)?
    
    /// Initializes a new task row.
    /// - Parameters:
    ///   - entity: Task to display.
    ///   - isLast: Whether the task is the last item in section.
    ///   - namespace: Animation namespace.
    ///   - onShowFolderSetup: Optional closure to handle showing folder setup UI.
    init(entity: TaskEntity, isLast: Bool, namespace: Namespace.ID, onShowFolderSetup: ((TaskEntity) -> Void)? = nil) {
        self._entity = ObservedObject(wrappedValue: entity)
        self.isLast = isLast
        self.namespace = namespace
        self.onShowFolderSetup = onShowFolderSetup
    }
    
    // MARK: - Body
    
    internal var body: some View {
        Button {
            handleTaskSelection()
        } label: {
            TaskListRow(entity: entity, isLast: isLast)            
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) { leadingSwipeActions }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) { trailingSwipeActions }
    }
    
    // MARK: - Actions
    
    /// Handles task selection (opens task editor).
    private func handleTaskSelection() {
        viewModel.selectedTask = entity
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        logger.debug("Tapped on a task to edit: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
    }
    
    /// Swipe actions on the leading side: important and pin.
    @ViewBuilder
    private var leadingSwipeActions: some View {
        toggleImportantButton
        togglePinnedButton
    }
    
    /// Swipe actions on the trailing side: share, move & remove.
    @ViewBuilder
    private var trailingSwipeActions: some View {
        removeButton
        folderButton
        shareButton
    }
    
    // MARK: - Individual Swipe Buttons
    
    /// Button to toggle important status.
    private var toggleImportantButton: some View {
        Button(role: viewModel.importance ? .destructive : .cancel) {
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.toggleImportant(for: entity)
                    logger.debug("Toggled important status to \(entity.important) for \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Toggling important status failed for \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                }
            }
            Toast.shared.present(
                title: entity.important
                ? Texts.Toasts.importantOn
                : Texts.Toasts.importantOff
            )
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
                    logger.debug("Toggled pinned status to \(entity.pinned) for \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Toggling pinned status failed for \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                }
            }
            Toast.shared.present(
                title: entity.pinned
                ? Texts.Toasts.pinnedOn
                : Texts.Toasts.pinnedOff
            )
        } label: {
            TaskService.taskCheckPinned(for: entity)
            ? Image.TaskManagement.TaskRow.SwipeAction.pinnedDeselect
            : Image.TaskManagement.TaskRow.SwipeAction.pinned
        }
        .tint(Color.SwipeColors.pin)
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
                    logger.debug("Task removed: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Task removal failed: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                }
            }
            Toast.shared.present(
                title: Texts.Toasts.removed)
        } label: {
            Image.TaskManagement.TaskRow.SwipeAction.remove
        }
        .tint(Color.SwipeColors.remove)
    }
}


#Preview {
    TodayTaskRowWithSwipeActions(entity: PreviewData.taskItem,
                                 isLast: false,
                                 namespace: Namespace().wrappedValue,
                                 onShowFolderSetup: nil)
    .environmentObject(TodayViewModel())
}
