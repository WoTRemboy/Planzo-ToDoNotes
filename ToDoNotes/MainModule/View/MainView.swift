//
//  MainView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject private var viewModel: MainViewModel
    @EnvironmentObject private var coreDataManager: CoreDataViewModel
    
    @Namespace private var animation
    
    internal var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            floatingButtons
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                namespace: animation) {
                    viewModel.toggleShowingCreateView()
            }
            .presentationDetents([.height(80 + viewModel.taskManagementHeight)])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $viewModel.selectedTask) { task in
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                entity: task,
                namespace: animation) {
                    viewModel.toggleShowingTaskEditView()
                }
        }
    }
        
    private var content: some View {
        VStack(spacing: 0) {
            MainCustomNavBar(title: Texts.MainPage.title)
                .zIndex(1)
            
            if coreDataManager.filteredSegmentedTasks(for: viewModel.selectedFilter).isEmpty {
                placeholderLabel
            } else {
                taskForm
            }
        }
        .animation(.easeInOut(duration: 0.2),
                   value: coreDataManager.isEmpty)
    }
    
    private var placeholderLabel: some View {
        Text(Texts.MainPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .font(.system(size: 18, weight: .medium))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var taskForm: some View {
        Form {
            ForEach(coreDataManager.filteredSegmentedTasks(for: viewModel.selectedFilter), id: \.0) { segment, tasks in
                segmentView(segment: segment, tasks: tasks)
            }
        }
        .padding(.horizontal, hasNotch() ? -4 : 0)
        .background(Color.BackColors.backDefault)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private func segmentView(segment: Date?, tasks: [TaskEntity]) -> some View {
        Section(header: segmentHeader(name: segment)) {
            ForEach(tasks) { entity in
                if #available(iOS 18.0, *) {
                    Button {
                        viewModel.selectedTask = entity
                    } label: {
                        TaskListRow(entity: entity)
                    }
                    .matchedTransitionSource(
                        id: "\(String(describing: entity.id))",
                        in: animation)
                } else {
                    Button {
                        viewModel.selectedTask = entity
                    } label: {
                        TaskListRow(entity: entity)
                    }
                }
            }
            .onDelete { indexSet in
                let idsToDelete = indexSet.map { tasks[$0].objectID }
                withAnimation {
                    coreDataManager.deleteTasks(with: idsToDelete)
                }
            }
            .listRowBackground(Color.SupportColors.backListRow)
            .listRowInsets(EdgeInsets())
        }
    }
    
    @ViewBuilder
    private func segmentHeader(name: Date?) -> some View {
        Text(name?.longDayMonthWeekday ?? String())
            .font(.system(size: 13, weight: .medium))
            .textCase(.none)
    }
    
    private var floatingButtons: some View {
        VStack(alignment: .trailing, spacing: 16) {
            Spacer()
//            scrollToTopButton
            plusButton
        }
        .padding(.horizontal)
        .ignoresSafeArea(.keyboard)
    }
    
    private var scrollToTopButton: some View {
        Button {
            
        } label: {
            Image.TaskManagement.scrollToTop
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
    }
    
    private var scrollToBottomButton: some View {
        Button {
            
        } label: {
            Image.TaskManagement.scrollToBottom
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
    }
    
    private var plusButton: some View {
        Button {
            viewModel.toggleShowingCreateView()
        } label: {
            Image.TaskManagement.plus
                .resizable()
                .scaledToFit()
                .frame(width: 58, height: 58)
        }
        .padding(.bottom)
        .glow(available: viewModel.addTaskButtonGlow)
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
        .environmentObject(CoreDataViewModel())
}
