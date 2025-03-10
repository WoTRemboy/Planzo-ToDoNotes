//
//  TaskDateParamRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/28/25.
//

import SwiftUI

struct TaskDateParamRow: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    private let type: TaskDateParam
    private let isLast: Bool
    
    init(type: TaskDateParam, isLast: Bool, viewModel: TaskManagementViewModel) {
        self.type = type
        self.isLast = isLast
        self.viewModel = viewModel
    }
    
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
                .foregroundStyle(Color.SupportColors.backListRow)
        )
    }
    
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
    
    private var titleLabel: Text {
        switch type {
        case .time:
            Text(Texts.TaskManagement.DatePicker.time)
        case .notifications:
            Text(Texts.TaskManagement.DatePicker.reminder)
        case .repeating:
            Text(Texts.TaskManagement.DatePicker.cycle)
        case .endRepeating:
            Text(Texts.TaskManagement.DatePicker.endCycle)
        }
    }
    
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
                    // "None" reminder button
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleNotificationSelection(
                                for: TaskNotification.none)
                        }
                    } label: {
                        reminderMenuContent(type: TaskNotification.none)
                    }
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
    
    private func repeatingMenuContent(type: TaskRepeating) -> some View {
        return HStack {
            Text(type.name)
            Spacer()
            
            if viewModel.selectedRepeating == type {
                Image.TaskManagement.DateSelector.checked
            }
        }
    }
    
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
    
    private func endRepeatingMenuContent(type: TaskEndRepeating) -> some View {
        return HStack {
            Text(type.name)
            Spacer()
            Image.TaskManagement.DateSelector.checked
        }
    }
    
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

#Preview {
    TaskDateParamRow(type: .notifications,
                     isLast: false,
                     viewModel: TaskManagementViewModel())
}
