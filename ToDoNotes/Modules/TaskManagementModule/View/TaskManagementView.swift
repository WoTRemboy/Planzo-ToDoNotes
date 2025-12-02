//
//  TaskManagementView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/6/25.
//

import SwiftUI
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.taskManagement", category: "TaskManagementView")

/// View for creating or editing a task.
struct TaskManagementView: View {
    
    // MARK: - Properties
    
    /// Focus state to control the keyboard focus on the task title input.
    @FocusState private var titleFocused
    /// View model for managing the task's data and UI state.
    @StateObject private var viewModel = TaskManagementViewModel()
    
    @EnvironmentObject private var authService: AuthNetworkService
    
    /// Binding to control the dynamic height of the management view (only used in pop-up mode).
    @Binding private var taskManagementHeight: CGFloat
    /// Indicates whether the keyboard is active.
    @State private var isKeyboardActive = false
    
    /// Identifier for transition animations.
    private var transitionID: String = Texts.NamespaceID.selectedEntity
    
    /// The task entity being edited, if any (nil for task creation).
    private let entity: TaskEntity?
    /// The folder associated with the task.
    private let folder: Folder?
    /// Animation namespace used for matched geometry transitions.
    private let animation: Namespace.ID
    /// Closure called when the view should be dismissed.
    private let onDismiss: () -> Void
    
    // MARK: - Initialization
    
    /// Initializes the task management view.
    ///
    /// - Parameters:
    ///   - taskManagementHeight: Binding to control the view height for pop-up mode.
    ///   - selectedDate: Optional date to prefill the target date for a new task.
    ///   - entity: Optional existing `TaskEntity` for editing mode.
    ///   - folder: Optional folder to associate the task with.
    ///   - namespace: Matched geometry namespace for smooth animations.
    ///   - onDismiss: Closure triggered when the view is dismissed.
    init(taskManagementHeight: Binding<CGFloat>,
         selectedDate: Date? = nil,
         entity: TaskEntity? = nil,
         folder: Folder? = nil,
         namespace: Namespace.ID,
         onDismiss: @escaping () -> Void
    ) {
        self._taskManagementHeight = taskManagementHeight
        self.onDismiss = onDismiss
        self.entity = entity
        self.folder = folder
        self.animation = namespace
        
        if let entity {
            // Edit mode: Initialize the view model with an existing task
            self._viewModel = StateObject(wrappedValue: TaskManagementViewModel(entity: entity))
            self.transitionID = entity.id?.uuidString ?? transitionID
        } else if let selectedDate {
            // Create mode with a preselected date
            self._viewModel = StateObject(wrappedValue: TaskManagementViewModel(targetDate: selectedDate))
        }
    }
    
    // MARK: - View Body
    
    internal var body: some View {
        FullSwipeNavigationStack {
            ZStack {
                // Background color for popup mode if no entity is being edited
                backgroundLayer
                
                VStack(spacing: 0) {
                    // Navigation bar for full-screen or edit modes
                    if shouldShowFullScreenContent {
                        TaskManagementNavBar(
                            viewModel: viewModel, entity: entity) {
                                duplicateTask()
                            } onDismiss: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if entity != nil {
                                        attemptPerformSave(thenDismiss: true)
                                    } else {
                                        onDismiss()
                                    }
                                }
                            }
                            .zIndex(1)  // Ensures the navbar stays above the content
                    }
                    content
                }
            }
        }
        // Setup on appear (keyboard events, default check status)
        .onAppear {
            subscribeToKeyboardNotifications()
            if entity == nil {
                viewModel.check = .none
            }
        }
        .task {
            if let entity = entity {
                let since = authService.currentUser?.lastSyncAt
                ListItemNetworkService.shared.syncChecklistForTaskEntity(entity, since: since) {
                    viewModel.reloadChecklist(from: entity.checklist)
                }
                NotificationNetworkService.shared.syncNotificationsIfNeeded(for: entity, since: since) {
                    viewModel.reloadNotifications(from: entity.notifications)
                    UNUserNotificationCenter.current().logNotifications(for: entity.notifications)
                }
                viewModel.loadMembersForSharingTaskWithToasts()
            }
        }
        // Share Sheet Presentation
        .sheet(item: $viewModel.sharingTask) { item in
            TaskManagementShareView(viewModel: viewModel) {
                viewModel.setSharingTask(to: nil)
            }
                .presentationDetents([.height(285)])
                .presentationDragIndicator(.visible)
        }
        // Date Picker Sheet Presentation
        .sheet(isPresented: $viewModel.showingDatePicker) {
            TaskCalendarSelectorView(
                entity: entity,
                viewModel: viewModel)
            .presentationDetents([.height(670)])
            .interactiveDismissDisabled()
        }
        .popView(isPresented: $viewModel.showingStopSharingAlert, onTap: {}, onDismiss: {}) {
            stopSharingAlert
        }
        // Matched Geometry Effect for Navigation
        .navigationTransition(
            id: transitionID,
            namespace: animation,
            enable: shouldShowFullScreenContent)
    }
    
    /// View background depending on the mode.
    private var backgroundLayer: some View {
        Group {
            if !shouldShowFullScreenContent {
                Color.BackColors.backSheet
                    .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Content View
    
    /// Main content block: task name, description, checklist, and action buttons.
    private var content: some View {
        VStack(spacing: 0) {
            // Scrollable form containing text fields and checklist
            ScrollView {
                // Title text field with optional checkbox
                nameInput
                
                if shouldShowFullScreenContent {
                    descriptionCoverInput   // Multiline description input
                    
                    TaskChecklistView(viewModel: viewModel) // Checklist (points) editor
                        .padding(.horizontal, -8)
                    
                    if viewModel.accessToEdit {
                        addPointButton  // "Add point" button
                    }
                } else {
                    // Simplified description field for sheet mode
                    descriptionSheetInput
                        .background(HeightReader(height: $taskManagementHeight))
                }
            }
            .scrollIndicators(.hidden)
            .scrollDisabled(!shouldShowFullScreenContent)
            .padding(.horizontal, !shouldShowFullScreenContent ? 16 : 24)
            
            Spacer()
            // Bottom bar with calendar button, check toggle and save button
            buttons
                .padding(.horizontal, 16)
        }
        .padding(.top, !shouldShowFullScreenContent ? 8 : 0)
        .padding(.bottom, 8)
    }
    
    // MARK: - Name Input
    
    /// Text field for the task name with optional check/uncheck button.
    private var nameInput: some View {
        HStack {
            // Optional checkbox
            if viewModel.check != .none {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleTitleCheck()
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }
                } label: {
                    titleCheckbox
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .disabled(!viewModel.accessToEdit)
            }
            
            // TextField for task title
            TextField(Texts.TaskManagement.titlePlaceholder,
                      text: $viewModel.nameText)
            .font(.system(size: 20, weight: .medium))
            .lineLimit(1)
            
            .foregroundStyle(
                viewModel.check == .checked
                ? Color.LabelColors.labelDetails
                : Color.LabelColors.labelPrimary)
            .strikethrough(viewModel.check == .checked)
            
            .focused($titleFocused)
            .immediateKeyboardIf(entity == nil || viewModel.currentRole == .owner, delay: shouldShowFullScreenContent ? 0.4 : 0)
            .onAppear {
                titleFocused = true
            }
            .disabled(!viewModel.accessToEdit)
        }
        .padding(.top, 16)
    }
    
    /// Image for button to toggle task completion status (checked/unchecked).
    private var titleCheckbox: Image {
        if viewModel.check == .unchecked {
            Image.TaskManagement.EditTask.Checklist.uncheck
        } else {
            Image.TaskManagement.EditTask.Checklist.check
        }
    }
    
    /// Description input for compact sheet mode.
    private var descriptionSheetInput: some View {
        TextField(Texts.TaskManagement.descriprionPlaceholder,
                  text: $viewModel.descriptionText,
                  axis: .vertical)
        
        .lineLimit(1...5)
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(
            viewModel.check == .checked
            ? Color.LabelColors.labelDetails
            : Color.LabelColors.labelPrimary)
    }
    
    /// Description input for fullscreen modes.
    private var descriptionCoverInput: some View {
        TextField(Texts.TaskManagement.descriprionPlaceholder,
                  text: $viewModel.descriptionText,
                  axis: .vertical)
        
        .fixedSize(horizontal: false, vertical: true)
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(
            viewModel.check == .checked
            ? Color.LabelColors.labelDetails
            : Color.LabelColors.labelPrimary)
        .disabled(!viewModel.accessToEdit)
    }
    
    /// Button to add a new checklist point.
    private var addPointButton: some View {
        Button {
            withAnimation(.bouncy(duration: 0.2)) {
                viewModel.appendChecklistItem()
            }
        } label: {
            Text(Texts.TaskManagement.addPoint)
                .foregroundStyle(Color.LabelColors.labelPlaceholder)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Bottom Action Buttons
    
    /// Bottom action buttons: calendar picker, check/uncheck toggle, and save button.
    private var buttons: some View {
        HStack(alignment: .bottom, spacing: 16) {
            calendarModule  // Button to select date
            checkButton     // Button to toggle task check status
            
            Spacer()
            if viewModel.accessToEdit {
                acceptButton    // Save (accept or update) button
                    .transition(.scale)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isKeyboardActive)
    }
    
    /// Button to open the calendar picker for setting a date and time.
    private var calendarModule: some View {
        Button {
            viewModel.toggleDatePicker()
        } label: {
            calendarImage
                .resizable()
                .frame(width: 24, height: 24)
            
            if viewModel.hasDate {
                Text(viewModel.hasTime
                     ? viewModel.targetDate.shortDayMonthHourMinutes
                     : viewModel.targetDate.shortDate)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
            }
        }
        .disabled(!viewModel.accessToEdit)
    }
    
    /// Returns the appropriate calendar icon depending on whether a date is set.
    private var calendarImage: Image {
        if viewModel.hasDate {
            Image.TaskManagement.EditTask.calendar
        } else {
            Image.TaskManagement.EditTask.calendarUnselected
        }
    }
    
    /// Button to toggle task completion status (checked/unchecked).
    private var checkButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleBottomCheck()
            }
        } label: {
            (viewModel.check != .none
             ? Image.TaskManagement.EditTask.check
             : Image.TaskManagement.EditTask.uncheck)
            .resizable()
            .frame(width: 24, height: 24)
        }
        .disabled(!viewModel.accessToEdit)
    }
    
    /// Button to save the new or updated task.
    private var acceptButton: some View {
        Button {
            withAnimation {
                attemptPerformSave(thenDismiss: true)
            }
        } label: {
            (entity != nil
             ? Image.TaskManagement.EditTask.ready
             : Image.TaskManagement.EditTask.accept)
            .resizable()
            .frame(width: 30, height: 30)
        }
    }
    
    private var syncErrorAlert: some View {
        CustomAlertView(
            title: Texts.Settings.Sync.Retry.title,
            message: Texts.Settings.Sync.Retry.content,
            primaryButtonTitle: Texts.Settings.Sync.Retry.cancel,
            primaryAction:
                viewModel.toggleShowingNetworkErrorAlert
            )
    }
    
    private var stopSharingAlert: some View {
        CustomAlertView(
            title: Texts.TaskManagement.ShareView.StopSharingAlert.title,
            message: Texts.TaskManagement.ShareView.StopSharingAlert.message,
            primaryButtonTitle: Texts.TaskManagement.ShareView.StopSharingAlert.stop,
            primaryAction:
                {
                    viewModel.removeAllMembersAndLinks { _ in }
                },
            secondaryButtonTitle: Texts.Settings.Sync.Retry.cancel,
            secondaryAction: viewModel.toggleShowingStopSharingAlert
            )
    }
}

// MARK: - Preview

struct TaskManagementView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
            .environmentObject(TaskManagementViewModel())
            .environmentObject(AuthNetworkService())
    }
    
    struct PreviewWrapper: View {
        @State private var taskManagementHeight: CGFloat = 130
        @Namespace private var namespace
        
        var body: some View {
            TaskManagementView(
                taskManagementHeight: $taskManagementHeight,
                namespace: namespace,
                onDismiss: { }
            )
        }
    }
}

// MARK: - Heplers

extension TaskManagementView {
    
    // MARK: - Full Screen Conditions
    
    /// Determines whether full-screen content should be displayed.
    private var shouldShowFullScreenContent: Bool {
        entity != nil || viewModel.taskCreationFullScreen == .fullScreen
    }
    
    // MARK: - Keyboard Notifications
    
    /// Subscribes to keyboard show and hide notifications.
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            isKeyboardActive = true
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            isKeyboardActive = false
        }
    }
    
    /// Unsubscribes from keyboard show and hide notifications.
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Task Management Methods
    
    /// Updates the existing task entity with the latest input values.
    private func updateTask() {
        if let entity, viewModel.accessToEdit {
            viewModel.setupUserNotifications(remove: entity.notifications)
            viewModel.disableButtonGlow()
            
            do {
                try TaskService.saveTask(
                    entity: entity,
                    name: viewModel.nameText,
                    description: viewModel.descriptionText,
                    completeCheck: viewModel.check,
                    target: viewModel.saveTargetDate,
                    hasTime: viewModel.hasTime,
                    importance: viewModel.importance,
                    pinned: viewModel.pinned,
                    removed: viewModel.removed,
                    notifications: viewModel.notificationsLocal,
                    checklist: viewModel.checklistLocal)
                logger.debug("Task updated successfully: \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown").")
            } catch {
                logger.error("Task update failed: \(entity.name ?? "unnamed") \(entity.id?.uuidString ?? "unknown") Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Creates a new task with the provided input values.
    private func addTask() {
        do {
            try TaskService.saveTask(
                name: viewModel.nameText,
                description: viewModel.descriptionText,
                completeCheck: viewModel.check,
                target: viewModel.saveTargetDate,
                hasTime: viewModel.hasTime,
                folder: folder,
                importance: viewModel.importance,
                pinned: viewModel.pinned,
                notifications: viewModel.notificationsLocal,
                checklist: viewModel.checklistLocal)
            
            viewModel.setupUserNotifications(remove: nil)
            viewModel.disableButtonGlow()
            logger.debug("Task added: \(viewModel.nameText)")
        } catch {
            logger.error("Task add Error: \(viewModel.nameText) \(error.localizedDescription)")
        }
    }
    
    /// Duplicates an existing task.
    private func duplicateTask() {
        do {
            try TaskService.duplicate(task: entity)
            if let entity, entity.completed != 2 {
                viewModel.setupUserNotifications(remove: nil)
            }
            Toast.shared.present(
                title: Texts.Toasts.duplicated)
            logger.debug("Task duplicated: \(entity?.name ?? "unnamed") \(entity?.id?.uuidString ?? "unknown")")
        } catch {
            Toast.shared.present(
                title: Texts.Toasts.duplicatedError)
            logger.error("Task \(entity?.name ?? "unnamed") \(entity?.id?.uuidString ?? "unknown") duplicate Error: \(error.localizedDescription)")
        }
    }
    
    /// Attempts to perform save (update or add) with role verification if needed.
    private func attemptPerformSave(thenDismiss: Bool) {
        // If editing an existing shared task and local role is .edit or .viewOnly, verify server role first
        if let entity = self.entity {
            if viewModel.currentRole == .edit || viewModel.currentRole == .viewOnly {
                guard let listId = entity.serverId, !listId.isEmpty else {
                    // No server id, allow local save
                    proceedWithSave(for: entity, thenDismiss: thenDismiss)
                    return
                }
                ShareAccessService.shared.getMyRole(for: listId) { result in
                    switch result {
                    case .success(let roleRaw):
                        let role = ShareAccess(rawValue: roleRaw) ?? .viewOnly
                        if role == .edit || role == .owner {
                            proceedWithSave(for: entity, thenDismiss: thenDismiss)
                        } else {
                            if thenDismiss { onDismiss() }
                        }
                    case .failure(_):
                        Toast.shared.present(title: Texts.Settings.Sync.Retry.title)
                        if thenDismiss { onDismiss() }
                    }
                }
                return
            }
            // Owner or no restriction -> proceed
            proceedWithSave(for: entity, thenDismiss: thenDismiss)
            return
        }
        // Adding a new task: if role is restricted, block (no server id to verify)
        if viewModel.currentRole == .edit {
            Toast.shared.present(title: Texts.Settings.Sync.Retry.title)
            if thenDismiss { onDismiss() }
            return
        }
        // Proceed with creation
        addTask()
        if thenDismiss { onDismiss() }
    }

    /// Proceeds with saving for an existing entity or adding a new one (already verified).
    private func proceedWithSave(for entity: TaskEntity, thenDismiss: Bool) {
        updateTask()
        if thenDismiss { onDismiss() }
    }
}

private extension View {
    @ViewBuilder
    func immediateKeyboardIf(_ condition: Bool, delay: Double) -> some View {
        if condition {
            self.immediateKeyboard(delay: delay)
        } else {
            self
        }
    }
}
