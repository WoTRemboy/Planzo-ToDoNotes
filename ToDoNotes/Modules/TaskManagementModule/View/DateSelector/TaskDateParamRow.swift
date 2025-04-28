//
//  TaskDateParamRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/28/25.
//

import SwiftUI

/// A view that displays a single row of a task date parameter, such as time, reminder, repeat, or end repeating settings.
struct TaskDateParamRow: View {
    
    // MARK: - Properties
    
    /// ViewModel controlling the current task management parameters.
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    /// Type of the parameter represented (time, notifications, repeating, endRepeating).
    private let type: TaskDateParam
    /// Flag indicating whether this is the last row.
    private let isLast: Bool
    
    // MARK: - Initialization
    
    /// Initializes a new TaskDateParamRow.
    /// - Parameters:
    ///   - type: The parameter type for this row.
    ///   - isLast: Whether this is the last element.
    ///   - viewModel: The associated TaskManagementViewModel.
    init(type: TaskDateParam, isLast: Bool, viewModel: TaskManagementViewModel) {
        self.type = type
        self.isLast = isLast
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    internal var body: some View {
        HStack(spacing: 0) {
            paramIcon
                .resizable()
                .frame(width: 18, height: 18)
                .padding(.leading, 14)
            titleLabel
                .font(.system(size: 17, weight: .regular))
                .lineLimit(1)
                .padding(.leading, 6)
            Spacer()
            selector
        }
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .foregroundStyle(Color.LabelColors.labelDetails)
                    .frame(height: 0.5)
                    .padding(.horizontal, 14)
            }
        }
        .background(
            Rectangle()
                .foregroundStyle(Color.SupportColors.supportParamRow)
        )
    }
    
    // MARK: - Subviews
    
    /// Icon representing the parameter type.
    private var paramIcon: Image {
        switch type {
        case .time:
            viewModel.hasTime ?
                Image.TaskManagement.DateSelector.timeSelected :
                    Image.TaskManagement.DateSelector.time
        case .notifications:
            !viewModel.notificationsLocal.isEmpty ?
                Image.TaskManagement.DateSelector.reminderSelected :
                    Image.TaskManagement.DateSelector.reminder
        case .repeating:
            Image.TaskManagement.DateSelector.cycle
        case .endRepeating:
            Image.TaskManagement.DateSelector.cycle
        }
    }
    
    /// Text label for the parameter type.
    private var titleLabel: Text {
        switch type {
        case .time:
            Text(Texts.TaskManagement.DatePicker.Time.title)
        case .notifications:
            Text(Texts.TaskManagement.DatePicker.Reminder.title)
        case .repeating:
            Text(Texts.TaskManagement.DatePicker.Repeat.title)
        case .endRepeating:
            Text(Texts.TaskManagement.DatePicker.Repeat.endTitle)
        }
    }
    
    /// Selector view for modifying the parameter value.
    private var selector: some View {
        HStack {
            switch type {
            case .time:
                timeSelector
            case .notifications:
                reminderSelector
            case .repeating:
                repeatingSelector
            case .endRepeating:
                endRepeatingSelector
            }
        }
    }
    
    // MARK: - Time Selector
    
    /// Time selection view using DatePicker.
    private var timeSelector: some View {
        menuLabel
            .overlay {
                DatePicker(String(),
                           selection: $viewModel.selectedTime,
                           displayedComponents: [.hourAndMinute])
                .onChange(of: viewModel.selectedTime) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedTimeType = .value(newValue)
                        viewModel.setupNotificationAvailability()
                    }
                }
                .labelsHidden()
                .blendMode(.destinationOver)
                .padding(.trailing,
                         viewModel.selectedTimeType == .none ? 16 : 70)
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedTime)
    }
    
    // MARK: - Reminder Selector
    
    /// Reminder selection menu.
    private var reminderSelector: some View {
        menuLabel
            .overlay {
                Menu {
                    ForEach(viewModel.availableNotifications, id: \.self) { notificationType in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.toggleNotificationSelection(
                                    for: notificationType)
                            }
                        } label: {
                            reminderMenuContent(type: notificationType)
                        }
                    }
                    reminderNoneButton
                } label: {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                }
                .blendMode(.destinationOver)
                .padding(.trailing,
                         viewModel.notificationsLocal.isEmpty ? 10 : 35)
            }
            .onAppear {
                viewModel.setupNotificationAvailability()
            }
            .onChange(of: viewModel.selectedDay) {
                viewModel.setupNotificationAvailability()
            }
    }
    
    /// "None" reminder button
    private var reminderNoneButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleNotificationSelection(
                    for: TaskNotification.none)
            }
        } label: {
            reminderMenuContent(type: TaskNotification.none)
        }
    }
    
    /// Content for each reminder menu option.
    private func reminderMenuContent(type: TaskNotification) -> some View {
        return HStack {
            Text(type.selectorName)
            Spacer()
            
            if viewModel.notificationsLocal.contains(where: { $0.type == type }) ||
                (viewModel.notificationsLocal.isEmpty && type == .none) {
                Image.TaskManagement.DateSelector.checked
            } else {
                Image.TaskManagement.DateSelector.unchecked
            }
        }
    }
    
    // MARK: - Repeating Selector
    
    /// Repeating selection menu.
    private var repeatingSelector: some View {
        menuLabel
            .overlay {
                Menu {
                    // "None" repeating button
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleRepeatingSelection(
                                for: TaskRepeating.none)
                        }
                    } label: {
                        repeatingMenuContent(type: TaskRepeating.none)
                    }
                    
                    ForEach(TaskRepeating.allCases, id: \.self) { repeatingType in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.toggleRepeatingSelection(
                                    for: repeatingType)
                            }
                        } label: {
                            repeatingMenuContent(type: repeatingType)
                        }
                    }
                } label: {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                }
                .blendMode(.destinationOver)
                .padding(.trailing,
                         viewModel.selectedRepeating == .none ? 10 : 35)
            }
    }
    
    /// Content for each repeating menu option.
    private func repeatingMenuContent(type: TaskRepeating) -> some View {
        return HStack {
            Text(type.name)
            Spacer()
            
            if viewModel.selectedRepeating == type {
                Image.TaskManagement.DateSelector.checked
            }
        }
    }
    
    // MARK: - End Repeating Selector
    
    /// End repeating selection.
    private var endRepeatingSelector: some View {
        menuLabel
            .overlay {
                Menu {
                    Button {
                        // End repeating selector logic
                    } label: {
                        endRepeatingMenuContent(
                            type: TaskEndRepeating.none)
                    }
                } label: {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                }
                .blendMode(.destinationOver)
                .padding(.trailing, 10)
            }
    }
    
    /// Content for end repeating menu.
    private func endRepeatingMenuContent(type: TaskEndRepeating) -> some View {
        return HStack {
            Text(type.name)
            Spacer()
            Image.TaskManagement.DateSelector.checked
        }
    }
    
    // MARK: - Menu Content
    
    /// General menu label with dynamic value and remove button.
    private var menuLabel: some View {
        HStack(spacing: 0) {
            Text(viewModel.menuLabel(for: type))
                .font(.system(size: 14, weight: .regular))
                .lineLimit(1)
                .foregroundStyle(
                    viewModel.showingMenuIcon(for: type) ?
                    Color.LabelColors.labelSecondary :
                        Color.LabelColors.labelPrimary)
            
            removeButton
        }
        .frame(height: 30)
        .transition(.slide)
    }
    
    /// Remove button or menu icon depending on the current parameter state.
    private var removeButton: some View {
        HStack {
            if !viewModel.showingMenuIcon(for: type) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.paramRemoveMethod(for: type)
                    }
                } label: {
                    Image.TaskManagement.DateSelector.remove
                        .resizable()
                        .frame(width: 12, height: 12)
                }
                .padding(.leading, 9)
                .padding(.trailing)
            } else {
                Image.TaskManagement.DateSelector.menu
                    .resizable()
                    .frame(width: 10, height: 20)
                    .padding(.leading, 9)
                    .padding(.trailing)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TaskDateParamRow(type: .notifications,
                     isLast: false,
                     viewModel: TaskManagementViewModel())
}
