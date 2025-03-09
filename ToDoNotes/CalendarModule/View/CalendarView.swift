//
//  CalendarView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct CalendarView: View {
    
    @FetchRequest(entity: TaskEntity.entity(), sortDescriptors: [])
    private var tasksResults: FetchedResults<TaskEntity>
    
    @EnvironmentObject private var viewModel: CalendarViewModel
    @Namespace private var animation
    
    internal var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            plusButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .popView(isPresented: $viewModel.showingCalendarSelector, onDismiss: {}) {
            CalendarMonthSelector()
        }
        
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
    
    private var separator: some View {
        Rectangle()
            .foregroundStyle(Color.clear)
            .frame(height: 0.36)
            .padding([.top, .horizontal])
    }
    
    private var taskForm: some View {
        Form {
            ForEach(TaskSection.availableRarities(for: dayTasks.keys), id: \.self) { section in
                taskSection(for: section)
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
    private func taskSection(for section: TaskSection) -> some View {
        Section {
            let tasks = dayTasks[section] ?? []
            ForEach(tasks) { entity in
                CalendarTaskRowWithActions(entity: entity,
                                           isLast: tasks.last == entity)
            }
            .listRowInsets(EdgeInsets())
        } header: {
            if section == .active {
                Text(viewModel.selectedDate.longDayMonthWeekday)
                    .font(.system(size: 15, weight: .medium))
                    .textCase(.none)
                    .contentTransition(.numericText(value: viewModel.selectedDate.timeIntervalSince1970))
                    .matchedGeometryEffect(
                        id: Texts.NamespaceID.selectedCalendarDate,
                        in: animation)
            } else {
                Text(section.name)
                    .font(.system(size: 15, weight: .medium))
                    .textCase(.none)
            }
        }
    }
    
    private var placeholder: some View {
        ScrollView {
            CalendarTaskFormPlaceholder(
                date: viewModel.selectedDate,
                namespace: animation)
            .padding(.top)
        }
        .scrollDisabled(true)
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

extension CalendarView {
    private var dayTasks: [TaskSection: [TaskEntity]] {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: viewModel.selectedDate)
        let filteredTasks = tasksResults.filter { task in
            let taskDate = calendar.startOfDay(for: task.target ?? task.created ?? Date.distantPast)
            return taskDate == day && !task.removed
        }
        var result: [TaskSection: [TaskEntity]] = [:]
        let pinned = filteredTasks.filter { $0.pinned }
        let active = filteredTasks.filter { !$0.pinned && $0.completed != 2 }
        let completed = filteredTasks.filter { !$0.pinned && $0.completed == 2 }
        
        if !pinned.isEmpty { result[.pinned] = pinned }
        if !active.isEmpty { result[.active] = active }
        if !completed.isEmpty { result[.completed] = completed }
        return result
    }
    
    private var datesWithTasks: [Date: Int] {
        var groupedDates: [Date: Int] = [:]
        
        for task in tasksResults {
            let referenceDate = task.target ?? task.created ?? Date.distantPast
            let day = Calendar.current.startOfDay(for: referenceDate)
            groupedDates[day, default: 0] += 1
        }
        return groupedDates
    }
}

#Preview {
    CalendarView()
        .environmentObject(CalendarViewModel())
}
