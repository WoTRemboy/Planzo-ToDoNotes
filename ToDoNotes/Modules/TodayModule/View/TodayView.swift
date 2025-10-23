//
//  TodayView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI
import TipKit

/// The main view displaying tasks for the current day.
struct TodayView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var viewModel: TodayViewModel
    @EnvironmentObject private var authService: AuthNetworkService
    /// Used for smooth matched geometry transitions between floating buttons and task management screens.
    @Namespace private var animation
    
    /// Fetched task results from Core Data.
    @FetchRequest(entity: TaskEntity.entity(), sortDescriptors: [])
    private var tasksResults: FetchedResults<TaskEntity>
    
    /// TipKit overview tip for the today page.
    private let overviewTip = TodayPageOverview()
    @State private var folderSetupTask: TaskEntity?
    
    // MARK: - Body
    
    internal var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            plusButton
            if dayTasks.isEmpty {
                placeholderLabel
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .popView(isPresented: $viewModel.showingFolderSetupView,
                 onDismiss: {}) {
            SelectorView<Folder>(
                title: Texts.Folders.title,
                label: { $0.name },
                options: viewModel.folders,
                selected: $viewModel.selectedTaskFolder,
                onCancel: {
                    viewModel.toggleShowingFolderSetupView()
                },
                onAccept: { _ in
                    if let task = folderSetupTask {
                        do {
                            try TaskService.updateFolder(for: task, to: viewModel.selectedTaskFolder)
                            Toast.shared.present(
                                title: "\(Texts.Toasts.changedFolder) \(viewModel.selectedTaskFolder.name)")
                        } catch {
                            Toast.shared.present(
                                title: Texts.Toasts.sameFolders)
                        }
                    }
                    viewModel.toggleShowingFolderSetupView()
                    folderSetupTask = nil
                },
                cancelTitle: Texts.Settings.cancel,
                acceptTitle: Texts.Settings.accept
            )
        }
        
        // Sheet for task creation
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                namespace: animation) {
                    viewModel.toggleShowingTaskCreateView()
                }
                .presentationDetents([.height(80 + viewModel.taskManagementHeight)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showingShareSheet) {
            TaskManagementShareView()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        // Fullscreen task creation
        .fullScreenCover(isPresented: $viewModel.showingTaskCreateViewFullscreen) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                namespace: animation) {
                    viewModel.toggleShowingTaskCreateView()
                }
        }
        // Fullscreen task editing
        .fullScreenCover(item: $viewModel.selectedTask) { task in
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                entity: task,
                namespace: animation) {
                    viewModel.toggleShowingTaskEditView()
                }
        }
    }
    
    // MARK: - Content Components
    
    /// The main content view containing the navigation bar and the task form.
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
    
    /// Label shown when there are no tasks for today.
    private var placeholderLabel: some View {
        Text(Texts.TodayPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    /// The form listing today's tasks, grouped by sections.
    private var taskForm: some View {
        Form {
            // Display a TipKit tip at the top
            TipView(overviewTip)
                .tipBackground(Color.FolderColors.other
                    .opacity(0.3))
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            
            // List of tasks grouped by section
            ForEach(TaskSection.availableRarities(for: dayTasks.keys), id: \.self) { section in
                taskFormSection(for: section)
            }
            .listRowSeparator(.hidden)
            .listSectionSpacing(0)
            
            // Empty space at the bottom
            Color.clear
                .frame(height: 50)
                .listRowBackground(Color.clear)
        }
        .padding(.horizontal, hasNotch() ? -4 : 0)
        .shadow(color: Color.ShadowColors.taskSection, radius: 10, x: 2, y: 2)
        .background(Color.BackColors.backDefault)
        .scrollContentBackground(.hidden)
        .scrollDisabled(dayTasks.isEmpty)
        .animation(.easeInOut(duration: 0.1), value: viewModel.searchText)
    }
    
    /// Creates a task section for a given `TaskSection` type.
    /// - Parameter section: The section type (pinned, active, completed).
    /// - Returns: A view representing the section with its tasks.
    @ViewBuilder
    private func taskFormSection(for section: TaskSection) -> some View {
        Section {
            let tasks = dayTasks[section] ?? []
            ForEach(tasks) { entity in
                TodayTaskRowWithSwipeActions(
                    entity: entity,
                    isLast: tasks.last == entity,
                    namespace: animation,
                    onShowFolderSetup: { task in
                        folderSetupTask = task
                        viewModel.setTaskFolder(to: task.folder)
                        viewModel.toggleShowingFolderSetupView()
                    })
            }
            .listRowInsets(EdgeInsets())
        } header: {
            Text(section.name)
                .font(.system(size: 15, weight: .medium))
                .textCase(.none)
        }
    }
    
    // MARK: - Plus Button
    
    /// Floating plus button for creating a new task.
    private var plusButton: some View {
        VStack {
            Spacer()
            Button {
                viewModel.toggleShowingTaskCreateView()
                overviewTip.invalidate(reason: .tipClosed)
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

// MARK: - Tasks Filtering

extension TodayView {
    /// Returns today's tasks, grouped into sections (pinned, active, completed).
    private var dayTasks: [TaskSection: [TaskEntity]] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: viewModel.todayDate)
        let filteredTasks = tasksResults.lazy
            .filter { task in
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
            // Sorting tasks by pinned status and nearest date/time
            .sorted { t1, t2 in
                if t1.pinned != t2.pinned {
                    return t1.pinned && !t2.pinned
                }
                
                let d1 = (t1.target != nil && t1.hasTargetTime) ? t1.target! : (Date.distantFuture + t1.created!.timeIntervalSinceNow)
                let d2 = (t2.target != nil && t2.hasTargetTime) ? t2.target! : (Date.distantFuture + t2.created!.timeIntervalSinceNow)
                return d1 < d2
            }
        
        // Grouping sorted tasks into sections
        var result: [TaskSection: [TaskEntity]] = [:]
        
        let pinned = filteredTasks.filter { $0.pinned }
        let active = filteredTasks.filter { !$0.pinned && $0.completed != 2 }
        let completed = filteredTasks.filter { !$0.pinned && $0.completed == 2 }
        
        if !pinned.isEmpty { result[.pinned] = pinned }
        if !active.isEmpty { result[.active] = active }
        if !completed.isEmpty { result[.completed] = completed }
        
        return result
    }
}

// MARK: - Preview

#Preview {
    TodayView()
        .environmentObject(TodayViewModel())
        .environmentObject(AuthNetworkService())
        .task {
            try? Tips.resetDatastore()
            try? Tips.configure([
                .datastoreLocation(.applicationDefault)])
        }
}

