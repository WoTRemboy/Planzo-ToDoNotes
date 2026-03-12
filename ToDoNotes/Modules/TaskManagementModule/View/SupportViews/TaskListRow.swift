//
//  TaskListRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/13/25.
//

import SwiftUI
import CoreData
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.taskManagement", category: "TaskListRow")

/// A single row displaying a task inside a task list with support for context menus and swipe actions.
struct TaskListRow: View {
    
    // MARK: - Properties
    
    /// The task entity to be displayed.
    @ObservedObject private var entity: TaskEntity
    /// The calculated status of the task (important, outdated, etc.).
    private let status: TaskStatus
    /// Indicating whether this is the last item in the section.
    private let isLast: Bool
    /// Optional callback to request confirmation for deleting a shared task (non-owner).
    private let onRequestConfirmSharedDelete: ((TaskEntity) -> Void)?
    /// Optional callback to request folder setup for a task.
    private let onShowFolderSetup: ((TaskEntity) -> Void)?
    
    // MARK: - Initialization
    
    /// Initializes the TaskListRow view.
    /// - Parameters:
    ///   - entity: The `TaskEntity` object representing the task.
    ///   - isLast: A Boolean indicating whether this is the last item in the section.
    ///   - onRequestConfirmSharedDelete: Optional closure to trigger shared-delete confirmation.
    ///   - onShowFolderSetup: Optional closure to show folder setup for this task.
    init(entity: TaskEntity, isLast: Bool, onRequestConfirmSharedDelete: ((TaskEntity) -> Void)? = nil, onShowFolderSetup: ((TaskEntity) -> Void)? = nil) {
        self._entity = ObservedObject(wrappedValue: entity)
        self.status = .setupStatus(for: entity)
        self.isLast = isLast
        self.onRequestConfirmSharedDelete = onRequestConfirmSharedDelete
        self.onShowFolderSetup = onShowFolderSetup
    }
    
    // MARK: - Body
    
    internal var body: some View {
        CustomContextMenu {
            content
                .background(Color.SupportColors.supportListRow)
        } preview: {
            TaskManagementPreview(
                entity: entity)
        } actions: {
            uiContextMenu
        } onEnd: {
            
        }
    }
    
    // MARK: - Main Content
    
    /// Main content inside the task row showing name, folder color, icons, and optional decorations.
    private var content: some View {
        HStack(spacing: 0) {
            folderIndicatior
            pinnedIndicator
            if entity.completed != 0 {
                checkBoxButton
            }
            nameSharedView
            
            Spacer()
            detailsBox
        }
        .frame(height: 62)
        
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundStyle(Color.LabelColors.labelDetails)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Folder and Pinned Indicators
    
    /// Displays a colored bar indicating the folder the task belongs to.
    private var folderIndicatior: some View {
        var color: Color = .clear
        let colorEntity = entity.folder?.color
        if let colorEntity {
            color = FolderColor.init(from: colorEntity).rgbToColor()
        }
        return Rectangle()
            .foregroundStyle(color)
            .frame(maxWidth: 6, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.2), value: entity.folder)
    }
    
    /// Displays a small dot if the task is pinned to top.
    private var pinnedIndicator: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            
            if entity.pinned {
                Image.TaskManagement.TaskRow.pinned
                    .resizable()
                    .frame(width: 5, height: 5)
                    .padding(.top, 5)
            }
        }
        .frame(maxWidth: 10, maxHeight: .infinity)
    }
    
    // MARK: - Task Completion Checkbox
    
    /// Displays a checkbox allowing the user to toggle task completion.
    private var checkBoxButton: some View {
        (TaskService.taskCheckStatus(for: entity) ?
         Image.TaskManagement.TaskRow.checkedBox :
            Image.TaskManagement.TaskRow.uncheckedBox)
        .resizable()
        .renderingMode(.template)
        .frame(width: 18, height: 18)
        
        .foregroundStyle(
            status == .outdated || TaskService.taskCheckStatus(for: entity) ?
            Color.LabelColors.labelDetails :
                Color.LabelColors.labelPrimary
        )
        
        .onTapGesture {
            guard !entity.removed, entity.role != ShareAccess.viewOnly.rawValue else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.toggleCompleteChecking(for: entity)
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    if entity.completed == 2 {
                        Toast.shared.present(
                            title: Texts.Toasts.completedOn)
                    }
                    logger.debug("Task checkbox successfully toggled to \(entity.completed) for \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Task checkbox toggle error: \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown") \(error.localizedDescription)")
                    Toast.shared.present(
                        title: Texts.Toasts.completedError)
                }
            }
        }
        .padding(.trailing, 8)
    }
    
    // MARK: - Task Name
    
    private var nameSharedView: some View {
        HStack(spacing: 8) {
            nameLabel
            if isSharedTask {
                sharingIcon
            }
        }
    }
    
    private var isSharedTask: Bool {
        if entity.members > 0 { return true }
        if let role = entity.role {
            return role == ShareAccess.viewOnly.rawValue || role == ShareAccess.edit.rawValue
        }
        return false
    }

    private var canEditTask: Bool {
        entity.role != ShareAccess.viewOnly.rawValue
    }

    private var canDuplicateTask: Bool {
        true
    }

    private var canChangeFolder: Bool {
        !isSharedTask && canEditTask && onShowFolderSetup != nil
    }
        
    /// Displays the task name with optional strikethrough and faded colors depending on the task state.
    private var nameLabel: some View {
        let name = entity.name ?? String()
        return Text(!name.isEmpty ? name : Texts.TaskManagement.TaskRow.placeholder)
            .font(.system(size: 18, weight: .medium))
            .lineLimit(1)
            .foregroundStyle(
                (TaskService.taskCheckStatus(for: entity)
                 || status == .outdated || name.isEmpty) ?
                Color.LabelColors.labelDetails :
                    Color.LabelColors.labelPrimary)
            .strikethrough(TaskService.taskCheckStatus(for: entity),
                           color: Color.LabelColors.labelDetails)
    }
    
    private var sharingIcon: some View {
        Image.TaskManagement.TaskRow.shared
            .resizable()
            .frame(width: 18, height: 18)
    }
    
    // MARK: - Details Section
    
    /// Displays additional info: due date, notifications, text content icon.
    private var detailsBox: some View {
        let hasDateLabel = entity.target != nil && entity.hasTargetTime
        let context = TaskService.haveTextContent(for: entity)
        let notifications = entity.notifications?.count ?? 0 > 0
        let spacingValue: CGFloat = (hasDateLabel && (context || notifications)) ? 6 : 0
        
        return VStack(alignment: .trailing, spacing: spacingValue) {
            if entity.target != nil, entity.hasTargetTime {
                dateLabel
            }
            
            HStack(spacing: 2) {
                if context {
                    textContentImage
                }
                if notifications {
                    reminderImage
                }
                if context || notifications || !hasDateLabel {
                    additionalStatus
                        .frame(width: 15, height: 15)
                }
            }
        }
        .padding(.trailing, 4)
    }
    
    /// Label showing formatted date/time if the task has target date set.
    private var dateLabel: some View {
        HStack(spacing: 2) {
            Text(entity.target?.fullHourMinutes ?? String())
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(
                    TaskService.taskCheckStatus(for: entity)
                    || status == .outdated ?
                    Color.LabelColors.labelDetails :
                        Color.LabelColors.labelPrimary)
            
            dateLabelAdditionalIcon
                .frame(width: 15, height: 15)
        }
    }
    
    /// Small icon indicating a notification reminder.
    private var reminderImage: some View {
        (TaskService.taskCheckStatus(for: entity) ?
         Image.TaskManagement.TaskRow.reminderOff :
            Image.TaskManagement.TaskRow.reminderOn)
        .resizable()
        .frame(width: 18, height: 18)
    }
    
    /// Small icon indicating text content is present.
    private var textContentImage: some View {
        Image.TaskManagement.TaskRow.contentOn
            .resizable()
            .frame(width: 18, height: 18)
    }
    
    /// Adds an additional icon depending on task status (expired, important).
    private var dateLabelAdditionalIcon: some View {
        Group {
            switch status {
            case .none:
                emptyRectangle
            case .outdated:
                Image.TaskManagement.TaskRow.expired
            case .important:
                Image.TaskManagement.TaskRow.important
            case .outdatedImportant:
                Image.TaskManagement.TaskRow.important
            }
        }
    }
    
    /// Adds an icon at the bottom right if needed (important without date, expired).
    private var additionalStatus: some View {
        Group {
            switch status {
            case .none:
                emptyRectangle
            case .outdated:
                emptyRectangle
            case .important:
                if entity.hasTargetTime {
                    emptyRectangle
                } else {
                    Image.TaskManagement.TaskRow.important
                }
            case .outdatedImportant:
                Image.TaskManagement.TaskRow.expired
            }
        }
    }
    
    /// Placeholder rectangle when no special status is shown.
    private var emptyRectangle: some View {
        Rectangle()
            .foregroundStyle(.clear)
    }
    
    // MARK: - Context Menu
    
    /// Defines a context menu when user long-presses a task row, allowing removing task.
    private var uiContextMenu: UIMenu {
        let importantAction = UIAction(
            title: entity.important
            ? Texts.TaskManagement.ContextMenu.importantDeselect
            : Texts.TaskManagement.ContextMenu.important,
            image: entity.important
            ? UIImage.TaskManagement.importantDeselect
            : UIImage.TaskManagement.importantSelect
        ) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.toggleImportant(for: entity)
                    Toast.shared.present(
                        title: entity.important ? Texts.Toasts.importantOn : Texts.Toasts.importantOff)
                    logger.debug("Toggled important status to \(entity.important) for task: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Toggle important status for task failed: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                }
            }
        }
        
        let pinnedAction = UIAction(
            title: entity.pinned
            ? Texts.TaskManagement.ContextMenu.unpin
            : Texts.TaskManagement.ContextMenu.pin,
            image: entity.pinned
            ? UIImage.TaskManagement.pinnedDeselect
            : UIImage.TaskManagement.pinnedSelect
        ) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.togglePinned(for: entity)
                    Toast.shared.present(
                        title: entity.pinned ? Texts.Toasts.pinnedOn : Texts.Toasts.pinnedOff)
                    logger.debug("Toggled pinned status to \(entity.pinned) for task: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                } catch {
                    logger.error("Toggle pinned status for task failed: \(entity.name ?? "unknown") \(entity.id?.uuidString ?? "unknown")")
                }
            }
        }
        
        let duplicateAction = UIAction(
            title: Texts.TaskManagement.ContextMenu.dublicate,
            image: UIImage.TaskManagement.copy
        ) { _ in
            do {
                try TaskService.duplicate(task: entity)
                Toast.shared.present(
                    title: Texts.Toasts.duplicated)
                logger.debug("Task duplicated: \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown")")
            } catch {
                Toast.shared.present(
                    title: Texts.Toasts.duplicatedError)
                logger.error("Task \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown") duplicate Error: \(error.localizedDescription)")
            }
        }
        
        let folderAction = UIAction(
            title: Texts.TaskManagement.ContextMenu.moveToFolder,
            image: UIImage(systemName: "folder")
        ) { _ in
            onShowFolderSetup?(entity)
        }
        
        let removeAction = UIAction(
            title: Texts.TaskManagement.ContextMenu.delete,
            image: UIImage.TaskManagement.trash,
            attributes: .destructive
        ) { _ in
            if let role = entity.role, role != ShareAccess.owner.rawValue {
                onRequestConfirmSharedDelete?(entity)
                return
            }
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    if entity.removed {
                        try TaskService.deleteRemovedTask(for: entity)
                        Toast.shared.present(title: Texts.Toasts.deleted)
                        logger.debug("Task permanently deleted: \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown").")
                    } else {
                        try TaskService.toggleRemoved(for: entity)
                        Toast.shared.present(title: Texts.Toasts.removed)
                        logger.debug("Task removed: \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown").")
                    }
                } catch {
                    logger.error("Task \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown") could not be removed with error: \(error.localizedDescription).")
                }
            }
        }
        
        if entity.removed {
            var removedActions = [UIMenuElement]()
            if entity.role == nil || entity.role == ShareAccess.owner.rawValue {
                let restoreAction = UIAction(
                    title: Texts.TaskManagement.ContextMenu.restore,
                    image: UIImage(systemName: "arrow.uturn.left")
                ) { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        do {
                            try TaskService.toggleRemoved(for: entity)
                            Toast.shared.present(title: Texts.Toasts.restored)
                            logger.debug("Task restored: \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown").")
                        } catch {
                            logger.error("Task restore failed: \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown") \(error.localizedDescription)")
                        }
                    }
                }
                removedActions.append(restoreAction)
            }
            removedActions.append(removeAction)
            return UIMenu(title: String(), children: removedActions)
        }
        
        var actions = [UIMenuElement]()
        if canEditTask {
            actions.append(contentsOf: [pinnedAction, importantAction])
        }
        if canDuplicateTask {
            actions.append(duplicateAction)
        }
        if canChangeFolder {
            actions.append(folderAction)
        }
        actions.append(removeAction)
        
        return UIMenu(title: String(), children: actions)
    }
}

// MARK: - Preview

#Preview {
    TaskListRow(entity: PreviewData.taskItem, isLast: false)
}
