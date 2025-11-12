//
//  MainView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import Foundation
import SwiftUI
import TipKit

// MARK: - MainView

/// The main view showing the list of tasks, floating action buttons, tips, and alerts.
/// Handles task creation, editing, filtering, and task management UI.
struct MainView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject private var viewModel: MainViewModel
    @EnvironmentObject private var authService: AuthNetworkService
    
    // MARK: - Properties
    
    /// Used for smooth matched geometry transitions between floating buttons and task management screens.
    @Namespace private var animation
    /// Tip to introduce the overview feature.
    private let overviewTip = MainPageOverview()
    @State private var folderSetupTask: TaskEntity?
    
    // Note: This view expects `viewModel` to provide task data such as `allTasks`,
    // along with segmented and filtered task arrays.
    // Please ensure the MainViewModel publishes these properties accordingly.
    
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
                   value: viewModel.allTasks.isEmpty)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .popView(isPresented: $viewModel.showingFolderSetupView,
                 onTap: {}, onDismiss: {}) {
            SelectorView<Folder>(
                title: Texts.Folders.title,
                label: { $0.localizedName },
                options: viewModel.folders.filter { !$0.system },
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
        
        // Configures and attaches sheets and full-screen covers for task creation and editing.
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                folder: viewModel.selectedFolder,
                namespace: animation) {
                    viewModel.toggleShowingCreateView()
                    viewModel.setFilter(to: .active)
                }
                .presentationDetents([.height(80 + viewModel.taskManagementHeight)])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $viewModel.sharingTask) { task in
            TaskManagementShareView(viewModel: TaskManagementViewModel(entity: task), onComplete: {
                viewModel.setSharingTask(to: nil)
            })
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        
        .fullScreenCover(isPresented: $viewModel.showingTaskCreateViewFullscreen) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                folder: viewModel.selectedFolder,
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
        .popView(isPresented: $viewModel.showingTaskRemoveAlert, onTap: {}, onDismiss: {}) {
            removeAlert
        }
        .popView(isPresented: $viewModel.showingTaskEditRemovedAlert, onTap: {}, onDismiss: {}) {
            editAlert
        }
        .popView(isPresented: $viewModel.showingSyncErrorAlert, onTap: {}, onDismiss: {}) {
            syncErrorAlert
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
        .modifier(RefreshModifier(authService: authService))
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
        .animation(.easeInOut(duration: 0.1), value: viewModel.allTasks.map { $0.folder })
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
    
    private var syncErrorAlert: some View {
        CustomAlertView(
            title: Texts.Settings.Sync.Retry.title,
            message: Texts.Settings.Sync.Retry.content,
            primaryButtonTitle: Texts.Settings.Sync.Retry.tryAgain,
            primaryAction: {
                viewModel.handleSync(authService: authService)
                viewModel.toggleShowingSyncErrorAlert()
            },
            secondaryButtonTitle: Texts.Settings.Sync.Retry.cancel,
            secondaryAction: viewModel.toggleShowingSyncErrorAlert)
    }
}

// MARK: - Filtering and Sorting Tasks

extension MainView {
    
    /// Access segmented and sorted tasks from the view model.
    private var segmentedAndSortedTasksArray: [(Date?, [TaskEntity])] {
        viewModel.segmentedAndSortedTasksArray
    }
    
    /// Access filtered segmented tasks from the view model.
    private var filteredSegmentedTasks: [(Date?, [TaskEntity])] {
        viewModel.filteredSegmentedTasks
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
