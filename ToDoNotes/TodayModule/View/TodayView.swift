//
//  TodayView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct TodayView: View {
    
    @EnvironmentObject private var viewModel: TodayViewModel
    @EnvironmentObject private var coreDataManager: CoreDataViewModel
    
    @Namespace private var animation
    
    internal var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            plusButton
            if coreDataManager.dayTasks.isEmpty {
                placeholderLabel
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .onAppear {
            coreDataManager.dayTasks(for: viewModel.todayDate, important: viewModel.importance)
        }
        .onChange(of: coreDataManager.savedEnities) {
            withAnimation {
                coreDataManager.dayTasks(for: viewModel.todayDate, important: viewModel.importance)
            }
        }
        .onChange(of: viewModel.importance) {
            withAnimation {
                coreDataManager.dayTasks(for: viewModel.todayDate, important: viewModel.importance)
            }
        }
        
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                namespace: animation) {
                    viewModel.toggleShowingTaskCreateView()
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
            TodayNavBar(date: viewModel.todayDate.shortDate,
                        day: viewModel.todayDate.shortWeekday)
                .zIndex(1)
            taskForm
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
            ForEach(TaskSection.availableRarities(for: coreDataManager.dayTasks.keys), id: \.self) { section in
                taskFormSection(for: section)
            }
            .listRowSeparator(.hidden)
            .listSectionSpacing(0)
        }
        .padding(.horizontal, hasNotch() ? -4 : 0)
        .background(Color.BackColors.backDefault)
        .shadow(color: Color.ShadowColors.shadowTaskSection, radius: 10, x: 2, y: 2)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private func taskFormSection(for section: TaskSection) -> some View {
        Section {
            let tasks = coreDataManager.dayTasks[section] ?? []
            ForEach(tasks) { entity in
                Button {
                    viewModel.selectedTask = entity
                } label: {
                    TaskListRow(entity: entity, isLast: tasks.last == entity)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button(role: (viewModel.importance && tasks.last == entity) ? .destructive : .cancel) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            coreDataManager.toggleImportant(for: entity)
                        }
                    } label: {
                        coreDataManager.taskCheckImportant(for: entity) ?
                            Image.TaskManagement.TaskRow.SwipeAction.importantDeselect :
                                Image.TaskManagement.TaskRow.SwipeAction.important
                    }
                    .tint(Color.SwipeColors.important)
                    
                    Button(role: .destructive) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            coreDataManager.togglePinned(for: entity)
                            coreDataManager.dayTasks(for: viewModel.todayDate, important: viewModel.importance)
                        }
                        
                    } label: {
                        coreDataManager.taskCheckPinned(for: entity) ?
                            Image.TaskManagement.TaskRow.SwipeAction.pinnedDeselect :
                                Image.TaskManagement.TaskRow.SwipeAction.pinned
                    }
                    .tint(Color.SwipeColors.pin)
                }
            }
            .onDelete { indexSet in
                let tasksForToday = coreDataManager.dayTasks[section] ?? []
                let idsToDelete = indexSet.map { tasksForToday[$0].objectID }
                
                withAnimation {
                    coreDataManager.deleteTasks(with: idsToDelete)
                }
            }
            .listRowInsets(EdgeInsets())
        } header: {
            Text(section.name)
                .font(.system(size: 15, weight: .medium))
                .textCase(.none)
        }
    }
    
    private var plusButton: some View {
        VStack {
            Spacer()
            Button {
                viewModel.toggleShowingTaskCreateView()
            } label: {
                Image.TaskManagement.plus
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
            }
            .navigationTransitionSource(id: Texts.NamespaceID.selectedEntity,
                                        namespace: animation)
            .padding()
            .glow(available: viewModel.addTaskButtonGlow)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    TodayView()
        .environmentObject(TodayViewModel())
        .environmentObject(CoreDataViewModel())
}
