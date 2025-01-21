//
//  TaskManagementView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/6/25.
//

import SwiftUI

struct TaskManagementView: View {
    
    @FocusState private var titleFocused
    
    @EnvironmentObject private var coreDataManager: CoreDataViewModel
    @StateObject private var viewModel = TaskManagementViewModel()
    
    @Binding private var taskManagementHeight: CGFloat
    
    private let date: Date
    private let entity: TaskEntity?
    private let onDismiss: () -> Void
    
    init(taskManagementHeight: Binding<CGFloat>,
         date: Date,
         entity: TaskEntity? = nil,
         onDismiss: @escaping () -> Void) {
        self._taskManagementHeight = taskManagementHeight
        self.date = date
        self.onDismiss = onDismiss
        self.entity = entity
        
        if let entity {
            self._viewModel = StateObject(wrappedValue: TaskManagementViewModel(entity: entity))
        }
    }
    
    internal var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if entity != nil {
                    TaskManagementNavBar(
                        title: date.shortDate,
                        dayName: date.shortWeekday,
                        onDismiss: onDismiss,
                        onShare: viewModel.toggleShareSheet)
                }
                content
            }
            
            if viewModel.showingDatePicker {
                calendarPicker
            }
        }
        .sheet(isPresented: $viewModel.showingShareSheet) {
            TaskManagementShareView()
                .presentationDetents([.height(285)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            ScrollView {
                nameInput
                
                if entity != nil {
                    descriptionCoverInput
                    TaskChecklistView(viewModel: viewModel)
                } else {
                    descriptionSheetInput
                        .background(HeightReader(height: $taskManagementHeight))
                }
            }
            .scrollDisabled(entity == nil)
            
            Spacer()
            buttons
        }
        .padding(.horizontal, 16)
        .padding(.top, entity == nil ? 8 : 0)
        .padding(.bottom, 8)
    }
    
    private var nameInput: some View {
        TextField(Texts.TaskManagement.titlePlaceholder,
                  text: $viewModel.nameText)
        .font(.system(size: 18, weight: .medium))
        .lineLimit(1)
        .padding(.top, 20)
        
        .focused($titleFocused)
        .immediateKeyboard()
        .onAppear {
            titleFocused = true
        }
    }
    
    private var descriptionSheetInput: some View {
        TextField(Texts.TaskManagement.descriprionPlaceholder,
                  text: $viewModel.descriptionText,
                  axis: .vertical)
        
        .lineLimit(1...5)
        .font(.system(size: 15, weight: .regular))
    }
    
    private var descriptionCoverInput: some View {
        TextField(Texts.TaskManagement.descriprionPlaceholder,
                  text: $viewModel.descriptionText,
                  axis: .vertical)
        
        .font(.system(size: 15, weight: .regular))
        .lineSpacing(2.5)
    }
    
    private var buttons: some View {
        HStack(spacing: 16) {
            if entity != nil {
                calendarModule
            }
            checkButton
            moreButton
            
            Spacer()
            acceptButton
        }
    }
    
    private var calendarModule: some View {
        HStack(spacing: 4) {
            calendarImage
            
            if entity?.target != nil || viewModel.targetDateSelected {
                Text(viewModel.targetDate.shortDayMonthHourMinutes)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleDatePicker()
                hideKeyboard()
            }
        }
    }
    
    private var calendarImage: some View {
        Image.TaskManagement.EditTask.calendar
            .resizable()
            .frame(width: 20, height: 20)
    }
    
    private var calendarPicker: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showingDatePicker = false
                    }
                }
            VStack {
                Spacer()
                TaskDateSelectorView(viewModel: viewModel)
                Spacer()
            }
        }
        .zIndex(1)
    }
    
    private var checkButton: some View {
        (viewModel.check ?
         Image.TaskManagement.EditTask.check :
            Image.TaskManagement.EditTask.uncheck)
        .resizable()
        .frame(width: 20, height: 20)
        
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleCheck()
            }
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
            guard !viewModel.nameText.isEmpty else { return }
            withAnimation {
                if let entity {
                    coreDataManager.updateTask(
                        entity: entity,
                        name: viewModel.nameText,
                        description: viewModel.descriptionText,
                        completeCheck: viewModel.check,
                        target: viewModel.saveTargetDate,
                        notify: viewModel.notificationsCheck,
                        checklist: viewModel.checklistLocal)
                } else {
                    coreDataManager.addTask(
                        name: viewModel.nameText,
                        description: viewModel.descriptionText,
                        completeCheck: viewModel.check,
                        target: nil,
                        notify: false)
                }
            }
            onDismiss()
        } label: {
            Image.TaskManagement.EditTask.accept
                .resizable()
                .frame(width: 30, height: 30)
        }
    }
}

struct TaskManagementView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
            .environmentObject(TaskManagementViewModel())
            .environmentObject(CoreDataViewModel())
    }
    
    struct PreviewWrapper: View {
        @State private var taskManagementHeight: CGFloat = 130
        
        var body: some View {
            TaskManagementView(
                taskManagementHeight: $taskManagementHeight,
                date: .now) { }
        }
    }
}
