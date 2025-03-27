//
//  TaskManagementView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/6/25.
//

import SwiftUI

struct TaskManagementView: View {
    
    @FocusState private var titleFocused
    @StateObject private var viewModel = TaskManagementViewModel()
    
    @Binding private var taskManagementHeight: CGFloat
    @State private var isKeyboardActive = false
    
    private let entity: TaskEntity?
    private let folder: Folder?
    private let animation: Namespace.ID
    private let onDismiss: () -> Void
    
    private var transitionID: String = Texts.NamespaceID.selectedEntity
    
    init(taskManagementHeight: Binding<CGFloat>,
         selectedDate: Date? = nil,
         entity: TaskEntity? = nil,
         folder: Folder? = nil,
         namespace: Namespace.ID,
         onDismiss: @escaping () -> Void) {
        self._taskManagementHeight = taskManagementHeight
        self.onDismiss = onDismiss
        self.entity = entity
        self.folder = folder
        self.animation = namespace
        
        if let entity {
            self._viewModel = StateObject(wrappedValue: TaskManagementViewModel(entity: entity))
            self.transitionID = entity.id?.uuidString ?? transitionID
        } else if let selectedDate {
            self._viewModel = StateObject(wrappedValue: TaskManagementViewModel(targetDate: selectedDate))
        }
    }
    
    internal var body: some View {
        ZStack {
            if entity == nil && viewModel.taskCreationFullScreen == .popup && folder != .lists {
                Color.BackColors.backSheet
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                if viewModel.taskCreationFullScreen == .fullScreen || folder == .lists || entity != nil {
                    TaskManagementNavBar(
                        viewModel: viewModel, entity: entity) {
                            duplicateTask()
                        } onDismiss: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                entity != nil ? updateTask() : nil
                                onDismiss()
                            }
                        }
                        .zIndex(1)
                }
                content
            }
        }
        .onAppear {
            subscribeToKeyboardNotifications()
            if entity == nil, folder == .tasks {
                viewModel.check = .unchecked
            }
        }
        .sheet(isPresented: $viewModel.showingShareSheet) {
            TaskManagementShareView()
                .presentationDetents([.height(285)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showingDatePicker) {
            TaskCalendarSelectorView(
                entity: entity,
                viewModel: viewModel)
                .presentationDetents([.height(670)])
        }
        .navigationTransition(
            id: transitionID,
            namespace: animation,
            enable: entity != nil || folder == .lists || viewModel.taskCreationFullScreen == .fullScreen)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            ScrollView {
                nameInput
                
                if entity != nil || folder == .lists || viewModel.taskCreationFullScreen == .fullScreen {
                    descriptionCoverInput
                    TaskChecklistView(viewModel: viewModel)
                } else {
                    descriptionSheetInput
                        .background(HeightReader(height: $taskManagementHeight))
                }
            }
            .scrollDisabled(entity == nil && viewModel.taskCreationFullScreen == .popup && folder != .lists)
            .padding(.horizontal, 24)
            
            Spacer()
            buttons
                .padding(.horizontal, 16)
        }
        .padding(.top, (entity == nil && viewModel.taskCreationFullScreen == .popup) ? 8 : 0)
        .padding(.bottom, 8)
    }
    
    private var nameInput: some View {
        HStack {
            if viewModel.check != .none {
                titleCheckbox
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleTitleCheck()
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }
                    }
            }
            
            TextField(Texts.TaskManagement.titlePlaceholder,
                      text: $viewModel.nameText)
            .font(.system(size: 20, weight: .medium))
            .lineLimit(1)
            
            .foregroundStyle(
                viewModel.check == .checked ?
                Color.LabelColors.labelDetails :
                    Color.LabelColors.labelPrimary)
            .strikethrough(viewModel.check == .checked)
            
            .focused($titleFocused)
            .immediateKeyboard(delay: (entity != nil || folder == .lists || viewModel.taskCreationFullScreen == .fullScreen) ? 0.4 : 0)
            .onAppear {
                titleFocused = true
            }
        }
        .padding(.top, 16)
    }
    
    private var titleCheckbox: Image {
        if viewModel.check == .unchecked {
            Image.TaskManagement.EditTask.checkListUncheck
        } else {
            Image.TaskManagement.EditTask.checkListCheck
        }
    }
    
    private var descriptionSheetInput: some View {
        TextField(Texts.TaskManagement.descriprionPlaceholder,
                  text: $viewModel.descriptionText,
                  axis: .vertical)
        
        .lineLimit(1...5)
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(
            viewModel.check == .checked ?
            Color.LabelColors.labelDetails :
                Color.LabelColors.labelPrimary)
    }
    
    private var descriptionCoverInput: some View {
        TextField(Texts.TaskManagement.descriprionPlaceholder,
                  text: $viewModel.descriptionText,
                  axis: .vertical)
        
        .fixedSize(horizontal: false, vertical: true)
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(
            viewModel.check == .checked ?
            Color.LabelColors.labelDetails :
                Color.LabelColors.labelPrimary)
    }
    
    private var buttons: some View {
        HStack(alignment: .bottom, spacing: 16) {
            calendarModule
            checkButton

            Spacer()
            acceptButton
                .transition(.scale)
        }
        .animation(.easeInOut(duration: 0.2), value: isKeyboardActive)
    }
    
    private var calendarModule: some View {
        Button {
            viewModel.toggleDatePicker()
        } label: {
            calendarImage
                .resizable()
                .frame(width: 24, height: 24)
            
            if viewModel.hasDate {
                Text(viewModel.hasTime ?
                     viewModel.targetDate.shortDayMonthHourMinutes :
                        viewModel.targetDate.shortDate)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
            }
        }
    }
    
    private var calendarImage: Image {
        if viewModel.hasDate {
            Image.TaskManagement.EditTask.calendar
        } else {
            Image.TaskManagement.EditTask.calendarUnselected
        }
    }
    
    private var checkButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleBottomCheck()
            }
        } label: {
            (viewModel.check != .none ?
             Image.TaskManagement.EditTask.check :
                Image.TaskManagement.EditTask.uncheck)
            .resizable()
            .frame(width: 24, height: 24)
        }
    }
    
    private var moreButton: some View {
        Button {
            // Action for more button
        } label: {
            Image.TaskManagement.EditTask.more
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    private var acceptButton: some View {
        Button {
//            guard !viewModel.nameText.isEmpty else { return }
            withAnimation {
                if entity != nil /*|| viewModel.taskCreationFullScreen == .fullScreen*/ {
                    updateTask()
                    onDismiss()
                } else {
                    addTask()
                    onDismiss()
                }
            }
        } label: {
            (entity != nil ?
            Image.TaskManagement.EditTask.ready :
            Image.TaskManagement.EditTask.accept)
                .resizable()
                .frame(width: 30, height: 30)
        }
    }
}

struct TaskManagementView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
            .environmentObject(TaskManagementViewModel())
    }
    
    struct PreviewWrapper: View {
        @State private var taskManagementHeight: CGFloat = 130
        
        var body: some View {
            TaskManagementView(
                taskManagementHeight: $taskManagementHeight,
                namespace: Namespace().wrappedValue)
            { }
        }
    }
}


extension TaskManagementView {
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            isKeyboardActive = true
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            isKeyboardActive = false
        }
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func updateTask() {
        if let entity {
            viewModel.setupUserNotifications(remove: entity.notifications)
            viewModel.disableButtonGlow()
            
            try? TaskService.saveTask(
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
        }
    }
    
    private func addTask() {
        try? TaskService.saveTask(
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
    }
    
    private func duplicateTask() {
        do {
            try TaskService.duplicate(task: entity)
            if let entity, entity.completed != 2 {
                viewModel.setupUserNotifications(remove: nil)
            }
            Toast.shared.present(
                title: Texts.Toasts.duplicated)
        } catch {
            print("Task duplicate Error: \(error.localizedDescription)")
            Toast.shared.present(
                title: Texts.Toasts.duplicatedError)
        }
    }
}
