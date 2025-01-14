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
    
    @State private var taskManagementHeight: CGFloat = 15
        
    internal var body: some View {
        ZStack {
            content
            plusButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $viewModel.showingTaskEditView) {
            TaskManagementView(taskManagementHeight: $taskManagementHeight) {
                viewModel.toggleShowingTaskEditView()
            }
                .presentationDetents([.height(80 + taskManagementHeight)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            TodayNavBar(date: viewModel.todayDate.shortDate,
                        day: viewModel.todayDate.shortWeekday)
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
            ForEach(coreDataManager.savedEnities) { entity in
                TaskListRow(entity: entity)
            }
            .onDelete { indexSet in
                coreDataManager.deleteTask(indexSet: indexSet)
            }
            .listRowBackground(Color.SupportColors.backListRow)
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
    TodayView()
        .environmentObject(TodayViewModel())
        .environmentObject(CoreDataViewModel())
}
