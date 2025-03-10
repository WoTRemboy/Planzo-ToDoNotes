//
//  MainView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct MainView: View {
    
    @FetchRequest(entity: TaskEntity.entity(), sortDescriptors: [])
    private var tasksResults: FetchedResults<TaskEntity>
    
    @EnvironmentObject private var viewModel: MainViewModel
    @Namespace private var animation
    
    internal var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            floatingButtons
            if filteredSegmentedTasks.isEmpty {
                placeholderLabel
            }
        }
        .animation(.easeInOut(duration: 0.2),
                   value: tasksResults.isEmpty)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: viewModel.searchText) { _, newValue in
            tasksResults.nsPredicate = TaskService.getTasksBySearchTerm(viewModel.searchText).predicate
        }
        
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
            ForEach(filteredSegmentedTasks, id: \.0) { segment, tasks in
                    segmentView(segment: segment, tasks: tasks)
                }
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
        }
        .padding(.horizontal, hasNotch() ? -4 : 0)
        .shadow(color: Color.ShadowColors.shadowTaskSection, radius: 10, x: 2, y: 2)
        .background(Color.BackColors.backDefault)
        .scrollContentBackground(.hidden)
        .animation(.easeInOut(duration: 0.1), value: tasksResults.count)
    }
    
    @ViewBuilder
    private func segmentView(segment: Date?, tasks: [TaskEntity]) -> some View {
        Section(header: segmentHeader(name: segment)) {
            ForEach(tasks) { entity in
                MainTaskRowWithActions(entity: entity,
                                       isLast: tasks.last == entity)
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
            } else if !filteredSegmentedTasks.isEmpty {
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
                    TaskService.deleteRemovedTasks()
                }
                viewModel.toggleShowingTaskRemoveAlert()
                Toast.shared.present(
                    title: Texts.Toasts.deletedAll)
            },
            secondaryButtonTitle: Texts.MainPage.RemoveFilter.alertCancel,
            secondaryAction: viewModel.toggleShowingTaskRemoveAlert)
    }
}

extension MainView {
    private var segmentedAndSortedTasksArray: [(Date?, [TaskEntity])] {
        let calendar = Calendar.current
        var grouped: [Date: [TaskEntity]] = [:]
        for task in tasksResults {
            let refDate = task.target ?? task.created ?? Date.distantPast
            let day = calendar.startOfDay(for: refDate)
            grouped[day, default: []].append(task)
        }
        return grouped.map { (key, tasks) in
            let sortedTasks = tasks.sorted { t1, t2 in
                if t1.pinned != t2.pinned {
                    return t1.pinned && !t2.pinned
                }
                
                let d1 = (t1.target != nil && t1.hasTargetTime) ? t1.target! : t1.created!
                let d2 = (t2.target != nil && t2.hasTargetTime) ? t2.target! : t2.created!
                return d1 < d2
            }
            return (key, sortedTasks)
        }
        .sorted { ($0.0 ?? Date.distantPast) < ($1.0 ?? Date.distantPast) }
    }
    
    private var filteredSegmentedTasks: [(Date?, [TaskEntity])] {
        let now = Date()
        return segmentedAndSortedTasksArray.compactMap { (date, tasks) in
            let filteredTasks = tasks.filter { task in
                
                switch viewModel.selectedFolder {
                case .all:
                    break
                case .reminders:
                    if task.notifications?.count ?? 0 < 1 {
                        return false
                    }
                case .lists:
                    if task.checklist?.count ?? 0 < 2 {
                        return false
                    }
                case .noDate:
                    if task.hasTargetTime {
                        return false
                    }
                }
                
                if viewModel.importance && !task.important { return false }
                switch viewModel.selectedFilter {
                case .active:
                    guard !task.removed else { return false }
                    guard task.completed != 2 else { return false }
                    if let target = task.target {
                        if task.hasTargetTime {
                            if target < now { return false }
                        } else {
                            if target < Calendar.current.startOfDay(for: now) { return false }
                        }
                    } else if let created = task.created {
                        if created < Calendar.current.startOfDay(for: now) { return false }
                    }
                    return true
                case .outdated:
                    guard !task.removed else { return false }
                    if task.completed == 1,
                       let target = task.target,
                       task.hasTargetTime,
                       target < now {
                        return true
                    }
                    return false
                case .completed:
                    guard !task.removed else { return false }
                    return task.completed == 2
                case .unsorted:
                    return !task.removed
                case .deleted:
                    return task.removed
                }
            }
            return filteredTasks.isEmpty ? nil : (date, filteredTasks)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
}
