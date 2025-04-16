//
//  MainView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI
import TipKit

struct MainView: View {
    
    @FetchRequest(entity: TaskEntity.entity(), sortDescriptors: [])
    private var tasksResults: FetchedResults<TaskEntity>
    
    @EnvironmentObject private var viewModel: MainViewModel
    @Namespace private var animation
    
    private let overviewTip = MainPageOverview()
    
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
        
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                folder: viewModel.selectedFolder != .all ? viewModel.selectedFolder : nil,
                namespace: animation) {
                    viewModel.toggleShowingCreateView()
                    viewModel.setFilter(to: .active)
                }
                .presentationDetents([.height(80 + viewModel.taskManagementHeight)])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $viewModel.showingTaskCreateViewFullscreen) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                folder: viewModel.selectedFolder != .all ? viewModel.selectedFolder : nil,
                namespace: animation) {
                    viewModel.toggleShowingCreateView()
                    viewModel.setFilter(to: .active)
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
        .popView(isPresented: $viewModel.showingTaskEditRemovedAlert, onDismiss: {}) {
            editAlert
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
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var taskForm: some View {
        Form {
            TipView(overviewTip)
                .tipBackground(Color.FolderColors.lists
                    .opacity(0.3))
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            
            ForEach(filteredSegmentedTasks, id: \.0) { segment, tasks in
                    segmentView(segment: segment, tasks: tasks)
                }
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
            
            Color.clear
                .frame(height: 50)
                .listRowBackground(Color.clear)
        }
        .padding(.horizontal, hasNotch() ? -4 : 0)
        .shadow(color: Color.ShadowColors.taskSection, radius: 10, x: 2, y: 2)
        .background(Color.BackColors.backDefault)
        .scrollContentBackground(.hidden)
        .scrollDisabled(filteredSegmentedTasks.isEmpty)
//        .animation(.easeInOut(duration: 0.1), value: viewModel.searchText)
    }
    
    @ViewBuilder
    private func segmentView(segment: Date?, tasks: [TaskEntity]) -> some View {
        Section(header: segmentHeader(name: segment)) {
            ForEach(tasks) { entity in
                MainTaskRowWithActions(
                    entity: entity,
                    isLast: tasks.last == entity)
            }
            .listRowInsets(EdgeInsets())
        }
    }
    
    @ViewBuilder
    private func segmentHeader(name: Date?) -> some View {
        Text(name?.longDayMonthWeekday ?? String())
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelDetails)
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
            overviewTip.invalidate(reason: .tipClosed)
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
            Text(Texts.MainPage.Filter.RemoveFilter.buttonTitle)
                .font(.system(size: 17, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: 58)
                .background(Color.LabelColors.labelPrimary)
                .foregroundColor(Color.LabelColors.labelReversed)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .matchedGeometryEffect(id: Texts.NamespaceID.floatingButtons, in: animation)
        .transition(.blurReplace)
        .padding(.bottom)
    }
    
    private var removeAlert: some View {
        CustomAlertView(
            title: Texts.MainPage.Filter.RemoveFilter.alertTitle,
            message: Texts.MainPage.Filter.RemoveFilter.alertContent,
            primaryButtonTitle: Texts.MainPage.Filter.RemoveFilter.alertYes,
            primaryAction: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    TaskService.deleteRemovedTasks()
                }
                viewModel.toggleShowingTaskRemoveAlert()
                Toast.shared.present(
                    title: Texts.Toasts.deletedAll)
            },
            secondaryButtonTitle: Texts.MainPage.Filter.RemoveFilter.alertCancel,
            secondaryAction: viewModel.toggleShowingTaskRemoveAlert)
    }
    
    private var editAlert: some View {
        CustomAlertView(
            title: Texts.MainPage.Filter.RemoveFilter.recoverAlertTitle,
            message: Texts.MainPage.Filter.RemoveFilter.recoverAlertContent,
            primaryButtonTitle: Texts.MainPage.Filter.RemoveFilter.alertRecover,
            primaryAction: {
                guard let task = viewModel.removedTask else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    try? TaskService.toggleRemoved(for: task)
                }
                viewModel.toggleShowingEditRemovedAlert()
            },
            secondaryButtonTitle: Texts.MainPage.Filter.RemoveFilter.alertCancel,
            secondaryAction: viewModel.toggleShowingEditRemovedAlert)
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
                
                let d1 = (t1.target != nil && t1.hasTargetTime) ? t1.target! : (Date.distantFuture + t1.created!.timeIntervalSinceNow)
                let d2 = (t2.target != nil && t2.hasTargetTime) ? t2.target! : (Date.distantFuture + t2.created!.timeIntervalSinceNow)
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
                if !viewModel.searchText.isEmpty {
                    let searchTerm = viewModel.searchText
                    let nameMatches = task.name?.localizedCaseInsensitiveContains(searchTerm) ?? false
                    let detailsMatches = task.details?.localizedCaseInsensitiveContains(searchTerm) ?? false
                    if !nameMatches && !detailsMatches {
                        return false
                    }
                }
                
                switch viewModel.selectedFolder {
                case .all:
                    break
                case .reminders:
                    if task.folder != Folder.reminders.rawValue {
                        return false
                    }
                case .tasks:
                    if task.folder != Folder.tasks.rawValue {
                        return false
                    }
                case .lists:
                    if task.folder != Folder.lists.rawValue {
                        return false
                    }
                case .other:
                    if task.folder != Folder.other.rawValue {
                        return false
                    }
                }
                
                if viewModel.importance && !task.important { return false }
                switch viewModel.selectedFilter {
                    
                case .active:
                    guard !task.removed else { return false }
                    guard task.completed != 2 else { return false }
                    if let target = task.target, task.hasTargetTime, target < now {
                        return false
                    }
                    if let count = task.notifications?.count, count > 0,
                       let target = task.target, target < now {
                        return false
                    }
                    return true
                    
                case .outdated:
                    guard !task.removed else { return false }
                    if task.completed == 1,
                       let target = task.target, task.hasTargetTime, target < now {
                        return true
                    }
                    return false
                    
                case .completed:
                    guard !task.removed else { return false }
                    return task.completed == 2
                    
                case .archived:
                    guard !task.removed else { return false }
                    guard task.completed != 2 else { return false }
                    
                    if let target = task.target, task.hasTargetTime, target < now {
                        return task.completed == 0
                    }
                    if let count = task.notifications?.count, count > 0,
                       let target = task.target, target < now {
                        return true
                    }
                    return false
                    
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
        .task {
            try? Tips.resetDatastore()
            try? Tips.configure([
                .datastoreLocation(.applicationDefault)])
        }
}
