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
    @EnvironmentObject private var viewModel: TaskManagementViewModel
    
    @Binding private var taskManagementHeight: CGFloat
    
    private var onDismiss: () -> Void
    
    init(taskManagementHeight: Binding<CGFloat>,
         onDismiss: @escaping () -> Void) {
        self._taskManagementHeight = taskManagementHeight
        self.onDismiss = onDismiss
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            nameInput
            descriptionInput
                .background(HeightReader(height: $taskManagementHeight))
            
            Spacer()
            buttons
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var sliderLine: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .foregroundStyle(Color.LabelColors.labelTertiary)
            .frame(width: 36, height: 5)
    }
    
    private var nameInput: some View {
        TextField(Texts.TaskManagement.titlePlaceholder,
                  text: $viewModel.nameText)
            .font(.system(size: 18, weight: .regular))
            .lineLimit(1)
            .padding(.top, 20)
        
            .focused($titleFocused)
            .onAppear {
                titleFocused = true
            }
    }
    
    private var descriptionInput: some View {
        TextField(Texts.TaskManagement.descriprionPlaceholder,
                  text: $viewModel.descriptionText,
                  axis: .vertical)
        .lineLimit(1...5)
        
        .font(.system(size: 15, weight: .light))
        .padding(.top, 10)
    }
    
    private var buttons: some View {
        HStack(spacing: 16) {
            calendarButton
            checkButton
            moreButton
            
            Spacer()
            acceptButton
        }
    }
    
    private var calendarButton: some View {
        Button {
            // Action for calendar button
        } label: {
            Image.TaskManagement.EditTask.calendar
                .resizable()
                .frame(width: 20, height: 20)
        }
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
                coreDataManager.addTask(
                    name: viewModel.nameText,
                    description: viewModel.descriptionText,
                    completeCheck: viewModel.check)
            }
            onDismiss()
        } label: {
            Image.TaskManagement.EditTask.accept
                .resizable()
                .frame(width: 30, height: 30)
        }
    }
}

struct HeightReader: View {
    @Binding private var height: CGFloat
    
    init(height: Binding<CGFloat>) {
        self._height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    height = geometry.size.height
                }
                .onChange(of: geometry.size.height) { newValue in
                    withAnimation {
                        height = newValue
                    }
                }
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
            TaskManagementView(taskManagementHeight: $taskManagementHeight) { }
        }
    }
}
