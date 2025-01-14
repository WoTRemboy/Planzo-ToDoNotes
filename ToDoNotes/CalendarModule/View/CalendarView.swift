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
        .sheet(isPresented: $viewModel.showingTaskEditView) {
            TaskManagementView(taskManagementHeight: $viewModel.taskManagementHeight) {
                viewModel.toggleShowingTaskEditView()
            }
            .presentationDetents([.height(80 + viewModel.taskManagementHeight)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            CalendarNavBar(date: Texts.CalendarPage.today,
                           monthYear: viewModel.todayDate.longMonthYear)
            CustomCalendarView()
                .padding(.top)
            
            separator
            
            if coreDataManager.isEmpty {
                CalendarTaskFormPlaceholder(date: viewModel.todayDate.longDayMonthWeekday)
                    .padding(.top)
            } else {
                taskForm
                    .padding(.top, 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.easeInOut(duration: 0.2),
                   value: coreDataManager.isEmpty)
    }
    
    private var separator: some View {
        Divider()
            .background(Color.LabelColors.labelTertiary)
            .frame(height: 0.36)
            .padding(.horizontal, 10)
            .padding(.top)
    }
    
    private var taskForm: some View {
        Form {
            Section {
                ForEach(coreDataManager.savedEnities) { entity in
                    TaskListRow(entity: entity)
                }
                .onDelete { indexSet in
                    coreDataManager.deleteTask(indexSet: indexSet)
                }
                .listRowBackground(Color.SupportColors.backListRow)
            } header: {
                Text(viewModel.todayDateString)
                    .font(.system(size: 13, weight: .regular))
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
                    viewModel.toggleShowingTaskEditView()
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
