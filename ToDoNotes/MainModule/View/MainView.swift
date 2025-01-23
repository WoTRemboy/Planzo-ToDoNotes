//
//  MainView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject private var viewModel: MainViewModel
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
                    viewModel.toggleShowingCreateView()
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
            MainCustomNavBar(title: Texts.MainPage.title)
            if coreDataManager.isEmpty {
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
            ForEach(coreDataManager.segmentedAndSortedTasks, id: \.0) { segment, tasks in
                Section(header: segmentHeader(name: segment)) {
                    ForEach(tasks) { entity in
                        Button {
                            viewModel.selectedTask = entity
                        } label: {
                            TaskListRow(entity: entity)
                        }
                    }
                    .onDelete { indexSet in
                        let idsToDelete = indexSet.map { tasks[$0].objectID }
                        withAnimation {
                            coreDataManager.deleteTasks(with: idsToDelete)
                        }
                    }
                    .listRowBackground(Color.SupportColors.backListRow)
                }
            }
        }
        .padding(.horizontal, -10)
        .background(Color.BackColors.backDefault)
        .scrollContentBackground(.hidden)
    }
    
    private func segmentHeader(name: Date?) -> some View {
        Text(name?.longDayMonthWeekday ?? String())
            .font(.system(size: 13, weight: .medium))
            .textCase(.none)
    }
    
    private var plusButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    viewModel.toggleShowingCreateView()
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
    MainView()
        .environmentObject(MainViewModel())
        .environmentObject(CoreDataViewModel())
}
