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
    
    internal var body: some View {
        ZStack {
            content
            plusButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                date: .now) {
                viewModel.toggleShowingTaskCreateView()
            }
            .presentationDetents([.height(80 + viewModel.taskManagementHeight)])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $viewModel.selectedTask) { task in
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                date: .now,
                entity: task) {
                    viewModel.toggleShowingTaskEditView()
                }
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            CalendarNavBar(date: Texts.CalendarPage.today,
                           monthYear: viewModel.todayDate.longMonthYear)
            CustomCalendarView()
                .padding(.top)
            
            separator
            
            if coreDataManager.dayTasks(for: viewModel.selectedDate).isEmpty {
                CalendarTaskFormPlaceholder(date: viewModel.selectedDate.longDayMonthWeekday)
                    .padding(.top)
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
        Divider()
            .background(Color.LabelColors.labelTertiary)
            .frame(height: 0.36)
            .padding(.top)
    }
    
    private var taskForm: some View {
        Form {
            Section {
                ForEach(coreDataManager.dayTasks(for: viewModel.selectedDate)) { entity in
                    Button {
                        viewModel.selectedTask = entity
                    } label: {
                        TaskListRow(entity: entity)
                    }
                }
                .onDelete { indexSet in
                    coreDataManager.deleteTask(indexSet: indexSet)
                }
                .listRowBackground(Color.SupportColors.backListRow)
            } header: {
                Text(viewModel.selectedDate.longDayMonthWeekday)
                    .font(.system(size: 13, weight: .medium))
                    .textCase(.none)
            }
        }
        .padding(.horizontal, -10)
        .background(Color.BackColors.backDefault)
        .scrollContentBackground(.hidden)
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
            }
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(CalendarViewModel())
        .environmentObject(CoreDataViewModel())
}
