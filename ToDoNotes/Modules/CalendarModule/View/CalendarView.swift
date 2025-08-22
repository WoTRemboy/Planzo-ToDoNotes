//
//  CalendarView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI
import TipKit

/// The main view for displaying a custom calendar and tasks for a selected day.
struct CalendarView: View {
    
    // MARK: - Properties
    
    /// Fetches all TaskEntity objects stored in Core Data.
    @FetchRequest(entity: TaskEntity.entity(), sortDescriptors: [])
    private var tasksResults: FetchedResults<TaskEntity>
    
    /// ViewModel managing the calendar's logic and state.
    @EnvironmentObject private var viewModel: CalendarViewModel
    /// Namespace for shared matched geometry effects between views.
    @Namespace private var animation
    
    /// Tip shown at the top of the task list to guide users.
    private let overviewTip = CalendarPageOverview()
    
    @State private var folderSetupTask: TaskEntity? = nil
    
    // MARK: - Body
    
    internal var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            plusButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        // Calendar month selector modal
        .popView(isPresented: $viewModel.showingCalendarSelector, onDismiss: {}) {
            CalendarMonthSelector()
        }
        .popView(isPresented: $viewModel.showingFolderSetupView,
                 onDismiss: {}) {
            SelectorView<Folder>(
                title: Texts.MainPage.Folders.title,
                label: { $0.name },
                options: Folder.selectCases,
                selected: $viewModel.selectedTaskFolder,
                onCancel: {
                    viewModel.toggleShowingFolderSetupView()
                },
                onAccept: { _ in
                    if let task = folderSetupTask {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            TaskService.updateFolder(for: task, to: viewModel.selectedTaskFolder.rawValue)
                        }
                    }
                    viewModel.toggleShowingFolderSetupView()
                    folderSetupTask = nil
                },
                cancelTitle: Texts.Settings.Appearance.cancel,
                acceptTitle: Texts.Settings.Appearance.accept
            )
        }
        // Task creation popup sheet
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                selectedDate: viewModel.selectedDate,
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
        // Task creation full screen
        .fullScreenCover(isPresented: $viewModel.showingTaskCreateViewFullscreen) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                selectedDate: viewModel.selectedDate,
                namespace: animation) {
                    viewModel.toggleShowingTaskCreateView()
                }
        }
        // Task editing full screen
        .fullScreenCover(item: $viewModel.selectedTask) { task in
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                entity: task,
                namespace: animation) {
                    viewModel.toggleShowingTaskEditView()
                }
        }
    }
    
    // MARK: - Main Content
    
    /// The main vertical stack containing navigation bar, calendar, separator, and task list or placeholder.
    private var content: some View {
        VStack(spacing: 0) {
            CalendarNavBar(date: Texts.CalendarPage.today,
                           monthYear: viewModel.calendarDate)
            .zIndex(1)
            
            CustomCalendarView(dates: datesWithTasks,
                               namespace: animation)
                .padding(.top)
            
            separator
            
            if dayTasks.isEmpty {
                placeholder
            } else {
                taskForm
                    .padding(.top, 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.easeInOut(duration: 0.15),
                   value: viewModel.selectedDate)
    }
    
    // MARK: - Subviews
    
    /// A thin separator between the calendar and the task list for better visual structure.
    private var separator: some View {
        Rectangle()
            .foregroundStyle(Color.clear)
            .frame(height: 0.36)
            .padding([.top, .horizontal])
    }
    
    /// Displays a list of tasks grouped into pinned, active, and completed sections.
    private var taskForm: some View {
        Form {
            overviewTipView
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            
            ForEach(TaskSection.availableRarities(for: dayTasks.keys), id: \.self) { section in
                taskSection(for: section)
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
    }
    
    /// Builds a section for a specific category of tasks (pinned, active, completed).
    private func taskSection(for section: TaskSection) -> some View {
        Section {
            let tasks = dayTasks[section] ?? []
            ForEach(tasks) { entity in
                CalendarTaskRowWithActions(
                    entity: entity,
                    isLast: tasks.last == entity,
                    onShowFolderSetup: { task in
                        folderSetupTask = task
                        viewModel.setTaskFolder(to: task.folder)
                        viewModel.toggleShowingFolderSetupView()
                    })
            }
            .listRowInsets(EdgeInsets())
        } header: {
            if section == .active {
                Text(viewModel.selectedDate.longDayMonthWeekday)
                    .font(.system(size: 15, weight: .medium))
                    .textCase(.none)
                    .contentTransition(.numericText(value: viewModel.selectedDate.timeIntervalSince1970))
            } else {
                Text(section.name)
                    .font(.system(size: 15, weight: .medium))
                    .textCase(.none)
            }
        }
    }
    
    /// A placeholder screen displayed when no tasks are scheduled for the selected date.
    private var placeholder: some View {
        ScrollView {
            overviewTipView
                .padding(.horizontal)
            
            CalendarTaskFormPlaceholder(
                date: viewModel.selectedDate,
                namespace: animation)
            .padding(.top)
        }
        .scrollIndicators(.hidden)
    }
    
    /// Tip view providing contextual help for the user.
    private var overviewTipView: some View {
        TipView(overviewTip)
            .tipBackground(Color.FolderColors.reminders
                .opacity(0.3))
    }
    
    /// A floating plus button to create new tasks.
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

// MARK: - Helpers

extension CalendarView {
    
    /// Groups tasks by type (pinned, active, completed) for the currently selected day.
    private var dayTasks: [TaskSection: [TaskEntity]] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: viewModel.selectedDate)
        
        let filteredTasks = tasksResults.lazy
            .filter { task in
            let taskDate = calendar.startOfDay(for: task.target ?? task.created ?? Date.distantPast)
            return taskDate == day && !task.removed
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
    
    /// Creates a dictionary mapping dates to the number of tasks scheduled for each date.
    private var datesWithTasks: [Date: Int] {
        var groupedDates: [Date: Int] = [:]
        
        for task in tasksResults {
            guard !task.removed else { continue }
            let referenceDate = task.target ?? task.created ?? Date.distantPast
            let day = Calendar.current.startOfDay(for: referenceDate)
            groupedDates[day, default: 0] += 1
        }
        return groupedDates
    }
}

// MARK: - Preview

#Preview {
    CalendarView()
        .environmentObject(CalendarViewModel())
        .task {
            try? Tips.resetDatastore()
            try? Tips.configure([
                .datastoreLocation(.applicationDefault)])
        }
}

