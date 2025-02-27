//
//  CalendarView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject private var viewModel: CalendarViewModel
    @EnvironmentObject private var coreDataManager: CoreDataViewModel
    
    @Namespace private var animation
    
    internal var body: some View {
        ZStack {
            content
            plusButton
            
            if viewModel.showingCalendarSelector {
                calendarSelector
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .onAppear {
            coreDataManager.dayTasks(for: viewModel.selectedDate)
        }
        .onChange(of: coreDataManager.savedEnities) { _ in
            withAnimation {
                coreDataManager.dayTasks(for: viewModel.selectedDate)
            }
        }
        .onChange(of: coreDataManager.dayTasksHasUpdated) { _ in
            withAnimation {
                coreDataManager.dayTasks(for: viewModel.selectedDate)
            }
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
                           monthYear: viewModel.calendarDate.longMonthYear)
            .zIndex(1)
            
            CustomCalendarView(namespace: animation)
                .padding(.top)
            
            separator
            
            if coreDataManager.dayTasks.isEmpty {
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
            ForEach(TaskSection.availableRarities(for: coreDataManager.dayTasks.keys), id: \.self) { section in
                taskSection(for: section)
            }
        }
        .padding(.horizontal, hasNotch() ? -4 : 0)
        .background(Color.BackColors.backDefault)
        .shadow(color: Color.ShadowColors.shadowTaskSection, radius: 10, x: 2, y: 2)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private func taskSection(for section: TaskSection) -> some View {
        Section {
            ForEach(coreDataManager.dayTasks[section] ?? []) { entity in
                    Button {
                        viewModel.selectedTask = entity
                    } label: {
                        TaskListRow(entity: entity)
                    }
                }
                .onDelete { indexSet in
                    let tasksForToday = coreDataManager.dayTasks[section] ?? []
                    let idsToDelete = indexSet.map { tasksForToday[$0].objectID }
                    
                    withAnimation {
                        coreDataManager.deleteTasks(
                            with: idsToDelete)
                    }
                }
                .listRowInsets(EdgeInsets())
        } header: {
            if section == .active {
                Text(viewModel.selectedDate.longDayMonthWeekday)
                    .font(.system(size: 15, weight: .medium))
                    .textCase(.none)
                    .contentTransition(.numericText())
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
                date: viewModel.selectedDate.longDayMonthWeekday,
                namespace: animation)
                .padding(.top)
        }
        .scrollDisabled(true)
    }
    
    private var plusButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    viewModel.toggleShowingTaskCreateView()
                } label: {
                    Image.TaskManagement.plus
                        .resizable()
                        .scaledToFit()
                        .frame(width: 58, height: 58)
                }
                .padding()
                .glow(available: viewModel.addTaskButtonGlow)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var calendarSelector: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleShowingCalendarSelector()
                    }
                }
            VStack {
                Spacer()
                CalendarMonthSelector()
                Spacer()
            }
        }
        .zIndex(1)
    }
}

#Preview {
    CalendarView()
        .environmentObject(CalendarViewModel())
        .environmentObject(CoreDataViewModel())
}
