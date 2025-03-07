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
            if coreDataManager.filteredSegmentedTasks(
                for: viewModel.selectedFilter, important: viewModel.importance).isEmpty {
                placeholderLabel
            }
        }
        .animation(.easeInOut(duration: 0.2),
                   value: coreDataManager.isEmpty)
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
        .fullScreenCover(isPresented: $viewModel.showingTaskCreateViewFullscreen) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                namespace: animation) {
                    viewModel.toggleShowingCreateView()
                }
        }
        .fullScreenCover(item: $viewModel.selectedTask) { task in
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                entity: task,
                namespace: animation) {
                    viewModel.toggleShowingTaskEditView()
                }
        }
        .popView(isPresented: $viewModel.showingTaskRemoveAlert, onDismiss: {}) {
            removeAlert
        }
    }
        
    private var content: some View {
        VStack(spacing: 0) {
            MainCustomNavBar(title: Texts.MainPage.title)
                .zIndex(1)
            taskForm
        }
    }
    
    private var placeholderLabel: some View {
        Text(Texts.MainPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .font(.system(size: 18, weight: .medium))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var taskForm: some View {
        Form {
            ForEach(coreDataManager.filteredSegmentedTasks(
                for: viewModel.selectedFilter,
                important: viewModel.importance), id: \.0) { segment, tasks in
                segmentView(segment: segment, tasks: tasks)
            }
            .listRowSeparator(.hidden)
            .listSectionSpacing(0)
        }
        .padding(.horizontal, hasNotch() ? -4 : 0)
        .shadow(color: Color.ShadowColors.shadowTaskSection, radius: 10, x: 2, y: 2)
        .background(Color.BackColors.backDefault)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private func segmentView(segment: Date?, tasks: [TaskEntity]) -> some View {
        Section(header: segmentHeader(name: segment)) {
            ForEach(tasks) { entity in
                Button {
                    viewModel.selectedTask = entity
                } label: {
                    TaskListRow(entity: entity, isLast: tasks.last == entity)
                }
                //.navigationTransitionSource(id: entity.id, namespace: animation)
                .swipeActions(edge: .leading, allowsFullSwipe: viewModel.selectedFilter == .deleted) {
                    if viewModel.selectedFilter != .deleted {
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
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                coreDataManager.togglePinned(for: entity)
                            }
                        } label: {
                            coreDataManager.taskCheckPinned(for: entity) ?
                            Image.TaskManagement.TaskRow.SwipeAction.pinnedDeselect :
                            Image.TaskManagement.TaskRow.SwipeAction.pinned
                        }
                        .tint(Color.SwipeColors.pin)
                    } else {
                        Button(role: .destructive) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                coreDataManager.toggleRemoved(for: entity)
                            }
                        } label: {
                            Image.TaskManagement.TaskRow.SwipeAction.restore
                        }
                        .tint(Color.SwipeColors.restore)
                    }
                }
                
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if viewModel.selectedFilter != .deleted {
                                coreDataManager.toggleRemoved(for: entity)
                            } else {
                                coreDataManager.deleteTask(for: entity)
                            }
                        }
                    } label: {
                        Image.TaskManagement.TaskRow.SwipeAction.remove
                    }
                    .tint(Color.SwipeColors.remove)
                }
            }
            .listRowInsets(EdgeInsets())
        }
    }
    
    @ViewBuilder
    private func segmentHeader(name: Date?) -> some View {
        Text(name?.longDayMonthWeekday ?? String())
            .font(.system(size: 15, weight: .medium))
            .textCase(.none)
    }
    
    private var floatingButtons: some View {
        VStack(alignment: .trailing, spacing: 16) {
            Spacer()
//            scrollToTopButton
            if viewModel.selectedFilter != .deleted {
                plusButton
            } else {
                removeAllTasksButton
            }
        }
        .padding(.horizontal)
        .ignoresSafeArea(.keyboard)
    }
    
    private var scrollToTopButton: some View {
        Button {
            // Scroll to Top Action
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
        .matchedGeometryEffect(id: Texts.NamespaceID.floatingButtons, in: animation)
        .transition(.blurReplace)
        .navigationTransitionSource(id: Texts.NamespaceID.selectedEntity,
                                    namespace: animation)
        .padding(.bottom)
        .glow(available: viewModel.addTaskButtonGlow)
    }
    
    private var removeAllTasksButton: some View {
        Button {
            viewModel.toggleShowingTaskRemoveAlert()
        } label: {
            Text(Texts.MainPage.RemoveFilter.buttonTitle)
                .font(.system(size: 17, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: 58)
                .background(Color.black)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .matchedGeometryEffect(id: Texts.NamespaceID.floatingButtons, in: animation)
        .transition(.blurReplace)
        .padding(.bottom)
    }
    
    private var removeAlert: some View {
        CustomAlertView(
            title: Texts.MainPage.RemoveFilter.alertTitle,
            message: Texts.MainPage.RemoveFilter.alertContent,
            primaryButtonTitle: Texts.MainPage.RemoveFilter.alertYes,
            primaryAction: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    coreDataManager.deleteRemovedTasks()
                }
                viewModel.toggleShowingTaskRemoveAlert()
            },
            secondaryButtonTitle: Texts.MainPage.RemoveFilter.alertCancel,
            secondaryAction: viewModel.toggleShowingTaskRemoveAlert)
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
        .environmentObject(CoreDataViewModel())
}
