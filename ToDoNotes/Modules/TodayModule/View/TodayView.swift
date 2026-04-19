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

    private let showsSelectedTaskCover: Bool
    
    /// TipKit overview tip for the today page.
    private let overviewTip = TodayPageOverview()
    @State private var folderSetupTask: TaskEntity?
    
    // MARK: - Body

    init(showsSelectedTaskCover: Bool = true) {
        self.showsSelectedTaskCover = showsSelectedTaskCover
    }
    
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
        .popView(isPresented: $viewModel.showingConfirmSharedDelete, onTap: {}, onDismiss: {}) {
            confirmSharedDeleteAlert
        }
        
        // Sheet for task creation
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                namespace: animation) {
                    viewModel.toggleShowingTaskCreateView()
                }
                .presentationDetents([.height(viewModel.taskManagementHeight)])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $viewModel.sharingTask) { task in
            TaskManagementShareView(viewModel: TaskManagementViewModel(entity: task)) {
                viewModel.setSharingTask(to: nil)
            }
                .presentationDetents([.height(330)])
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
        .modifier(SelectedTaskCoverModifier(
            isEnabled: showsSelectedTaskCover,
            selectedTask: $viewModel.selectedTask,
            taskManagementHeight: $viewModel.taskManagementHeight,
            animation: animation,
            onDismiss: viewModel.toggleShowingTaskEditView
        ))
    }

    // MARK: - Content Components
    
    /// The main content view containing the navigation bar and the task form.
    @ViewBuilder
    private var content: some View {
        let base = taskForm
            .modifier(RefreshModifier(authService: authService))
            .animation(.easeInOut(duration: 0.2),
                       value: viewModel.dayTasks.isEmpty)

        if #available(iOS 26.0, *) {
            base.safeAreaBar(edge: .top) {
                TodayNavBar(date: viewModel.todayDate.shortDate,
                            day: viewModel.todayDate.shortWeekday)
            }
        } else {
            base.safeAreaInset(edge: .top) {
                TodayNavBar(date: viewModel.todayDate.shortDate,
                            day: viewModel.todayDate.shortWeekday)
                    .zIndex(1)
            }
        }
    }
    
    /// Label shown when there are no tasks for today.
    private var placeholderLabel: some View {
        Text(Texts.TodayPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    /// The form listing today's tasks, grouped by sections.
    @ViewBuilder
    private var taskForm: some View {
        let form = Form {
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
        .defaultBackgroundStyle()
        .scrollContentBackground(.hidden)
        .scrollDisabled(dayTasks.isEmpty)

        if #available(iOS 26.0, *) {
            form.contentMargins(.top, 16, for: .scrollContent)
        } else {
            form
        }
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
            FloatingPlusButton(
                action: {
                    viewModel.toggleShowingTaskCreateView()
                    overviewTip.invalidate(reason: .tipClosed)
                },
                namespace: animation,
                glowAvailable: viewModel.addTaskButtonGlow,
                matchedGeometryID: nil)
            .padding()
        }
        .ignoresSafeArea(.keyboard)
    }
}

private struct SelectedTaskCoverModifier: ViewModifier {
    let isEnabled: Bool
    @Binding var selectedTask: TaskEntity?
    @Binding var taskManagementHeight: CGFloat
    let animation: Namespace.ID
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        if isEnabled {
            content.fullScreenCover(item: $selectedTask) { task in
                TaskManagementView(
                    taskManagementHeight: $taskManagementHeight,
                    entity: task,
                    namespace: animation
                ) {
                    onDismiss()
                }
            }
        } else {
            content
        }
    }
}

// MARK: - Tasks Filtering

extension TodayView {
    /// Returns today's tasks, grouped into sections (pinned, active, completed).
    private var dayTasks: [TaskSection: [TaskEntity]] {
        viewModel.dayTasks
    }
}

// MARK: - Alerts

extension TodayView {
    /// Alert to confirm deletion of a shared task when user is not the owner (same as in Main).
    private var confirmSharedDeleteAlert: some View {
        CustomAlertView(
            title: Texts.TaskManagement.SharingAccess.RemoveMeAlert.title,
            message: Texts.TaskManagement.SharingAccess.RemoveMeAlert.message,
            primaryButtonTitle: Texts.MainPage.Filter.RemoveFilter.alertYes,
            primaryAction: {
                viewModel.performConfirmSharedDelete()
            },
            secondaryButtonTitle: Texts.MainPage.Filter.RemoveFilter.alertCancel,
            secondaryAction: {
                viewModel.cancelConfirmSharedDelete()
            })
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

