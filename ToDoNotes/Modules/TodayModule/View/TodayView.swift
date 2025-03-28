//
//  TodayView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct TodayView: View {
    
    @EnvironmentObject private var viewModel: TodayViewModel
    @Namespace private var animation
    
    @FetchRequest(entity: TaskEntity.entity(), sortDescriptors: [])
    private var tasksResults: FetchedResults<TaskEntity>
    
    internal var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            plusButton
            if dayTasks.isEmpty {
                placeholderLabel
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                namespace: animation) {
                    viewModel.toggleShowingTaskCreateView()
                }
                .presentationDetents([.height(80 + viewModel.taskManagementHeight)])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $viewModel.showingTaskCreateViewFullscreen) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                namespace: animation) {
                    viewModel.toggleShowingTaskCreateView()
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
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            TodayNavBar(date: viewModel.todayDate.shortDate,
                        day: viewModel.todayDate.shortWeekday)
                .zIndex(1)
            taskForm
        }
        .animation(.easeInOut(duration: 0.2),
                   value: tasksResults.isEmpty)
    }
    
    private var placeholderLabel: some View {
        Text(Texts.TodayPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var taskForm: some View {
        Form {
            ForEach(TaskSection.availableRarities(for: dayTasks.keys), id: \.self) { section in
                taskFormSection(for: section)
            }
            .listRowSeparator(.hidden)
            .listSectionSpacing(0)
            
            Color.clear
                .frame(height: 50)
                .listRowBackground(Color.clear)
        }
        .padding(.horizontal, hasNotch() ? -4 : 0)
        .background(Color.BackColors.backDefault)
        .shadow(color: Color.ShadowColors.taskSection, radius: 10, x: 2, y: 2)
        .scrollContentBackground(.hidden)
//        .animation(.easeInOut(duration: 0.1), value: tasksResults.count)
    }
    
    @ViewBuilder
    private func taskFormSection(for section: TaskSection) -> some View {
        Section {
            let tasks = dayTasks[section] ?? []
            ForEach(tasks) { entity in
                TodayTaskRowWithSwipeActions(
                    entity: entity,
                    isLast: tasks.last == entity,
                    namespace: animation)
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

extension TodayView {
    private var dayTasks: [TaskSection: [TaskEntity]] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: viewModel.todayDate)
        let filteredTasks = tasksResults.filter { task in
            if !viewModel.searchText.isEmpty {
                let searchTerm = viewModel.searchText
                let nameMatches = task.name?.localizedCaseInsensitiveContains(searchTerm) ?? false
                let detailsMatches = task.details?.localizedCaseInsensitiveContains(searchTerm) ?? false
                if !nameMatches && !detailsMatches {
                    return false
                }
            }
            
            let taskDate = calendar.startOfDay(for: task.target ?? task.created ?? Date.distantPast)
            return taskDate == day && !task.removed && (!viewModel.importance || task.important)
        }
        let sortedTasks = filteredTasks.sorted { t1, t2 in
            let d1 = (t1.target != nil && t1.hasTargetTime) ? t1.target! : (Date.distantFuture + t1.created!.timeIntervalSinceNow)
            let d2 = (t2.target != nil && t2.hasTargetTime) ? t2.target! : (Date.distantFuture + t2.created!.timeIntervalSinceNow)
            return d1 < d2
        }
        var result: [TaskSection: [TaskEntity]] = [:]
        let pinned = sortedTasks.filter { $0.pinned }
        let active = sortedTasks.filter { !$0.pinned && $0.completed != 2 }
        let completed = sortedTasks.filter { !$0.pinned && $0.completed == 2 }
        
        if !pinned.isEmpty { result[.pinned] = pinned }
        if !active.isEmpty { result[.active] = active }
        if !completed.isEmpty { result[.completed] = completed }
        return result
    }
}

#Preview {
    TodayView()
        .environmentObject(TodayViewModel())
}
