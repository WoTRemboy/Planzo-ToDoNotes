//
//  TodayView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct TodayView: View {
    
    @EnvironmentObject private var viewModel: TodayViewModel
    @EnvironmentObject private var coreDataManager: CoreDataViewModel
    
    internal var body: some View {
        ZStack {
            content
            plusButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $viewModel.showingTaskCreateView) {
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight) {
                    viewModel.toggleShowingTaskCreateView()
                }
                .presentationDetents([.height(80 + viewModel.taskManagementHeight)])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $viewModel.selectedTask) { task in
            TaskManagementView(
                taskManagementHeight: $viewModel.taskManagementHeight,
                entity: task) {
                    viewModel.toggleShowingTaskEditView()
                }
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            TodayNavBar(date: viewModel.todayDate.shortDate,
                        day: viewModel.todayDate.shortWeekday)
            if coreDataManager.dayTasks(
                for: viewModel.todayDate).isEmpty {
                placeholderLabel
            } else {
                taskForm
            }
        }
        .animation(.easeInOut(duration: 0.2),
                   value: coreDataManager.isEmpty)
    }
    
    private var placeholderLabel: some View {
        Text(Texts.MainPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .font(.system(size: 18, weight: .medium))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var taskForm: some View {
        Form {
            Section {
                ForEach(coreDataManager.dayTasks(for: viewModel.todayDate)) { entity in
                    Button {
                        viewModel.selectedTask = entity
                    } label: {
                        TaskListRow(entity: entity)
                    }
                }
                .onDelete { indexSet in
                    let tasksForToday = coreDataManager.dayTasks(for: viewModel.todayDate)
                    let idsToDelete = indexSet.map { tasksForToday[$0].objectID }
                    
                    withAnimation {
                        coreDataManager.deleteTasks(with: idsToDelete)
                    }
                }
                .listRowBackground(Color.SupportColors.backListRow)
                .listRowInsets(EdgeInsets())
            } header: {
                Text(Texts.TodayPage.notCompleted)
                    .font(.system(size: 13, weight: .medium))
                    .textCase(.none)
            }
        }
        .padding(.horizontal, hasNotch() ? -4 : 0)
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
                .glow(available: viewModel.addTaskButtonGlow)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    TodayView()
        .environmentObject(TodayViewModel())
        .environmentObject(CoreDataViewModel())
}
