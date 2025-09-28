//
//  MainView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI
import TipKit

// MARK: - MainView

/// The main view showing the list of tasks, floating action buttons, tips, and alerts.
/// Handles task creation, editing, filtering, and task management UI.
struct MainView: View {
    
    // MARK: - Core Data Fetch
    
    /// Fetches all task entities without any initial sorting.
    @FetchRequest(entity: TaskEntity.entity(), sortDescriptors: [])
    private var tasksResults: FetchedResults<TaskEntity>
    
    // MARK: - Environment
    
    @EnvironmentObject private var viewModel: MainViewModel
    @EnvironmentObject private var authService: AuthNetworkService
    
    // MARK: - Properties
    
    /// Used for smooth matched geometry transitions between floating buttons and task management screens.
    @Namespace private var animation
    /// Tip to introduce the overview feature.
    private let overviewTip = MainPageOverview()
    @State private var folderSetupTask: TaskEntity?
    
    // MARK: - Body
    
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
        .popView(isPresented: $viewModel.showingFolderSetupView,
                 onDismiss: {}) {
            SelectorView<Folder>(
                title: Texts.MainPage.Folders.title,
                label: { $0.name },
                options: Folder.availableCases(isAuthorized: authService.isAuthorized),
                selected: $viewModel.selectedTaskFolder,
                onCancel: {
                    viewModel.toggleShowingFolderSetupView()
                },
                onAccept: { _ in
                    if let task = folderSetupTask {
                        do {
                            try TaskService.updateFolder(for: task, to: viewModel.selectedTaskFolder.rawValue)
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
        
        // Configures and attaches sheets and full-screen covers for task creation and editing.
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
        .sheet(isPresented: $viewModel.showingShareSheet) {
            TaskManagementShareView()
                .presentationDetents([.height(300)])
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
        .fullScreenCover(isPresented: $viewModel.showingSubscriptionPage) {
            SubscriptionView(namespace: animation, networkService: authService)
        }
        
        // Configures and attaches pop-up alerts for removing or recovering tasks.
        .popView(isPresented: $viewModel.showingTaskRemoveAlert, onDismiss: {}) {
            removeAlert
        }
        .popView(isPresented: $viewModel.showingTaskEditRemovedAlert, onDismiss: {}) {
            editAlert
        }
    }
    
    // MARK: - Main Content Layout
    
    /// Displays the navigation bar and task form inside the main screen.
    private var content: some View {
        VStack(spacing: 0) {
            MainCustomNavBar(title: Texts.MainPage.title, namespace: animation)
                .zIndex(1)
            taskForm
        }
    }
    
    /// Placeholder text shown when no tasks are available under current filters.
    private var placeholderLabel: some View {
        Text(Texts.MainPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    /// Displays the task list organized into segments and sections.
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
        
        .animation(.easeInOut(duration: 0.1), value: viewModel.searchText)
        .animation(.easeInOut(duration: 0.1), value: tasksResults.map { $0.folder })
    }
}

// MARK: - Segment Views

extension MainView {
    
    /// Displays a section for a specific segment (date) containing multiple tasks.
    @ViewBuilder
    private func segmentView(segment: Date?, tasks: [TaskEntity]) -> some View {
        Section(header: segmentHeader(name: segment)) {
            ForEach(tasks) { entity in
                MainTaskRowWithActions(
                    entity: entity,
                    isLast: tasks.last == entity,
                    onShowFolderSetup: { task in
                        folderSetupTask = task
                        viewModel.setTaskFolder(to: task.folder)
                        viewModel.toggleShowingFolderSetupView()
                    }
                )
            }
            .listRowInsets(EdgeInsets())
        }
    }
    
    /// Displays a header for a segment, showing the date in a formatted style.
    @ViewBuilder
    private func segmentHeader(name: Date?) -> some View {
        Text(name?.longDayMonthWeekday ?? String())
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelDetails)
            .textCase(.none)
    }
}

// MARK: - Floating Buttons

extension MainView {
    
    /// Floating buttons displayed in the bottom right corner: plus button or remove all tasks button depending on context.
    private var floatingButtons: some View {
        VStack(alignment: .trailing, spacing: 16) {
            Spacer()
            // scrollToTopButton (Placeholder for future scroll-to-top button)
            if viewModel.selectedFilter != .deleted {
                plusButton
            } else if !filteredSegmentedTasks.isEmpty {
                removeAllTasksButton
            }
        }
        .padding(.horizontal)
        .ignoresSafeArea(.keyboard)
    }
    
    /// Plus button to create a new task.
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
    
    /// Button to remove all deleted tasks.
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
}

// MARK: - Alerts

extension MainView {
    
    /// Confirmation alert to delete all tasks from the deleted section.
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
    
    /// Alert allowing users to recover a deleted task.
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

// MARK: - Filtering and Sorting Tasks

extension MainView {
    
    /// Segments and sorts tasks by their associated dates, applying pinning and deadlines.
    private var segmentedAndSortedTasksArray: [(Date?, [TaskEntity])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: tasksResults.lazy) { task -> Date in
            let refDate = task.target ?? task.created ?? Date.distantPast
            return calendar.startOfDay(for: refDate)
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
    
    /// Applies filters based on search, folder selection, importance, and task status.
    private var filteredSegmentedTasks: [(Date?, [TaskEntity])] {
        segmentedAndSortedTasksArray.lazy.compactMap { (date, tasks) in
            let filteredTasks = tasks.lazy.filter { task in
                if !viewModel.searchText.isEmpty {
                    let searchTerm = viewModel.searchText
                    let nameMatches = task.name?.localizedCaseInsensitiveContains(searchTerm) ?? false
                    let detailsMatches = task.details?.localizedCaseInsensitiveContains(searchTerm) ?? false
                    if !nameMatches && !detailsMatches {
                        return false
                    }
                }
                
                guard viewModel.taskMatchesFolder(for: task) else { return false }
                if viewModel.importance && !task.important { return false }
                return viewModel.taskMatchesFilter(for: task)
            }
            
            return filteredTasks.isEmpty ? nil : (date, Array(filteredTasks))
        }
        .sorted { ($0.0 ?? Date.distantPast) < ($1.0 ?? Date.distantPast) }
    }
}

// MARK: - Preview

#Preview {
    MainView()
        .environmentObject(MainViewModel())
        .environmentObject(AuthNetworkService())
        .task {
            try? Tips.resetDatastore()
            try? Tips.configure([
                .datastoreLocation(.applicationDefault)])
        }
}

