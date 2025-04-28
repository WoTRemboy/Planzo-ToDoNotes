//
//  TaskDateSelectorView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/21/25.
//

import SwiftUI

/// A view that allows the user to select a date and optionally enable notifications for a task.
struct TaskDateSelectorView: View {
    
    // MARK: - Properties
    
    /// The view model controlling the task data and date picker state.
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    // MARK: - Initialization
    
    /// Initializes the view with the provided TaskManagementViewModel.
    /// - Parameter viewModel: An instance of `TaskManagementViewModel` to bind UI actions to.
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
    
    // MARK: - Title Section
    
    /// The title label displayed at the top of the modal.
    private var title: some View {
        Text(Texts.TaskManagement.DatePicker.title)
            .font(.system(size: 17, weight: .medium))
            .padding(.top)
    }
    
    // MARK: - Selection Section
    
    /// Block containing the DatePicker and Notification Toggle.
    private var selectionBlock: some View {
        VStack(spacing: 16) {
            datePicker
            notificationToggle
        }
        .padding(.vertical)
    }
    
    /// A DatePicker allowing the user to pick a target date.
    private var datePicker: some View {
        DatePicker(
            "\(Texts.TaskManagement.DatePicker.target):",
            selection: $viewModel.targetDate
        )
        .padding(.horizontal)
    }
    
    /// A toggle allowing the user to enable or disable notifications for the selected date.
    private var notificationToggle: some View {
        Toggle(
            "\(Texts.TaskManagement.DatePicker.Reminder.title):",
            isOn: $viewModel.notificationsCheck
        )
        .padding(.horizontal)
    }
    
    // MARK: - Buttons Section
    
    /// Horizontal stack containing Cancel and Done buttons.
    private var buttons: some View {
        HStack(spacing: 16) {
            cancelButton
            doneButton
        }
    }
    
    /// A button that confirms and saves the selected date.
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
        .buttonStyleModifier()
        .padding([.trailing, .bottom])
    }
    
    /// A button that cancels the date selection.
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
        .buttonStyleModifier()
        .padding([.leading, .bottom])
    }
}

// MARK: - Button Style Modifier

private extension View {
    
    /// A reusable style modifier for the buttons in the TaskDateSelectorView.
    func buttonStyleModifier() -> some View {
        self
            .minimumScaleFactor(0.4)
            .foregroundStyle(Color.white)
            .tint(Color.LabelColors.labelPrimary)
            .buttonStyle(.bordered)
    }
}

// MARK: - Preview

#Preview {
    TaskDateSelectorView(viewModel: TaskManagementViewModel())
}
