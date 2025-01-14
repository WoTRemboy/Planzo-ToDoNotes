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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var taskForm: some View {
        Form {
            Section {
                ForEach(coreDataManager.savedEnities) { entity in
                    TaskListRow(entity: entity)
                        .onTapGesture {
                            viewModel.selectedTask = entity
                        }
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
