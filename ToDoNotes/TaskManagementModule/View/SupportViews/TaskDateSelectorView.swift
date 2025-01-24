//
//  TaskDateSelectorView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/21/25.
//

import SwiftUI

struct TaskDateSelectorView: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    init(viewModel: TaskManagementViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    internal var body: some View {
        VStack(spacing: 16) {
            title
            selectionBlock
            buttons
        }
        .frame(width: 350)
        .background(Color.BackColors.backSecondary)
        .cornerRadius(12)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Title
    
    private var title: some View {
        Text(Texts.TaskManagement.DatePicker.title)
            .font(.system(size: 17, weight: .medium))
            .padding(.top)
    }
    
    private var selectionBlock: some View {
        VStack(spacing: 16) {
            datePicker
            notificationToggle
        }
        .padding(.vertical)
    }
    
    private var datePicker: some View {
        DatePicker("\(Texts.TaskManagement.DatePicker.target):", selection: $viewModel.targetDate)
            .padding(.horizontal)
    }
    
    private var notificationToggle: some View {
        Toggle("\(Texts.TaskManagement.DatePicker.notification):", isOn: $viewModel.notificationsCheck)
            .padding(.horizontal)
    }
    
    // MARK: - Done Button
    
    private var buttons: some View {
        HStack(spacing: 16) {
            cancelButton
            doneButton
        }
    }
    
    private var doneButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.showDate(to: true)
                viewModel.doneDatePicker()
            }
        } label: {
            Text(Texts.TaskManagement.DatePicker.done)
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .foregroundStyle(Color.white)
        .tint(Color.LabelColors.labelPrimary)
        .buttonStyle(.bordered)
        
        .padding([.trailing, .bottom])
    }
    
    private var cancelButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.showDate(to: false)
                viewModel.cancelDatePicker()
            }
        } label: {
            Text(Texts.TaskManagement.DatePicker.cancel)
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .foregroundStyle(Color.white)
        .tint(Color.LabelColors.labelPrimary)
        .buttonStyle(.bordered)
        
        .padding([.leading, .bottom])
    }
}
// MARK: - Preview

#Preview {
    TaskDateSelectorView(viewModel: TaskManagementViewModel())
}
