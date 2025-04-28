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
    
    // MARK: - Initialization
    
    /// Initializes the TaskListRow view.
    /// - Parameters:
    ///   - entity: The `TaskEntity` object representing the task.
    ///   - isLast: A Boolean indicating whether this is the last item in the section.
    init(entity: TaskEntity, isLast: Bool) {
        self._entity = ObservedObject(wrappedValue: entity)
        self.status = .setupStatus(for: entity)
        self.isLast = isLast
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
            nameLabel
            
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
        let folder = Folder(rawValue: entity.folder ?? String())
        let color = folder?.color ?? .clear
        return Rectangle()
            .foregroundStyle(color)
            .frame(maxWidth: 6, maxHeight: .infinity)
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
            guard !entity.removed else { return }
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
        let removeAction = UIAction(
            title: Texts.TaskManagement.ContextMenu.delete,
            image: UIImage.TaskManagement.trash,
            attributes: .destructive
        ) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.toggleRemoved(for: entity)
                    Toast.shared.present(
                        title: Texts.Toasts.removed)
                    logger.debug("Task removed: \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown").")
                } catch {
                    logger.error("Task \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown") could not be removed with error: \(error.localizedDescription).")
                }
            }
        }
        
        return UIMenu(title: String(), children: [
            removeAction
        ])
    }
}

// MARK: - Preview

#Preview {
    TaskListRow(entity: PreviewData.taskItem, isLast: false)
}
