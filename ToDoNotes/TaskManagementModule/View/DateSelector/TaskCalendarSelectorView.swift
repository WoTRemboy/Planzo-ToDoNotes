//
//  TaskCalendarSelectorView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/28/25.
//

import SwiftUI

struct TaskCalendarSelectorView: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    init(viewModel: TaskManagementViewModel) {
        self.viewModel = viewModel
    }
    
    internal var body: some View {
        NavigationStack {
            VStack {
                calendarSection
                separator
                paramsForm
                Spacer()
                removeButton
            }
            .navigationTitle(Texts.TaskManagement.DatePicker.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    toolBarButtonCancel
                }
                ToolbarItem(placement: .topBarTrailing) {
                    toolBarButtonDone
                }
            }
        }
    }
    
    private var toolBarButtonCancel: some View {
        Button {
            viewModel.toggleDatePicker()
        } label: {
            Text(Texts.TaskManagement.DatePicker.cancel)
                .font(.system(size: 17, weight: .regular))
        }
    }
    
    private var toolBarButtonDone: some View {
        Button {
            // Done button Action
        } label: {
            Text(Texts.TaskManagement.DatePicker.done)
                .font(.system(size: 17, weight: .semibold))
        }
    }
    
    private var calendarSection: some View {
        TaskCustomCalendar(viewModel: viewModel)
    }
    
    private var separator: some View {
        Divider()
            .background(Color.LabelColors.labelTertiary)
            .frame(height: 0.36)
            .padding([.top, .horizontal])
    }
    
    private var paramsForm: some View {
        VStack(spacing: 0) {
            TaskDateParamRow(type: .time,
                             viewModel: viewModel)
            TaskDateParamRow(type: .notifications,
                             viewModel: viewModel)
            TaskDateParamRow(type: .repeating,
                             viewModel: viewModel)
            TaskDateParamRow(type: .endRepeating,
                             viewModel: viewModel)
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding()
    }
    
    private var removeButton: some View {
        Button {
            // Remove button logic
        } label: {
            Text(Texts.TaskManagement.DatePicker.removeAll)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.ButtonColors.remove)
        }
    }
}

#Preview {
    TaskCalendarSelectorView(viewModel: TaskManagementViewModel())
}
