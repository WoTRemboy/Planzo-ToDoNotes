//
//  TaskDateParamRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/28/25.
//

import SwiftUI

struct TaskDateParamRow: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    private let type: TaskDateParamType
    
    init(type: TaskDateParamType, viewModel: TaskManagementViewModel) {
        self.type = type
        self.viewModel = viewModel
    }
    
    internal var body: some View {
        HStack(spacing: 0) {
            paramIcon
                .resizable()
                .frame(width: 15, height: 15)
                .padding(.leading, 14)
            titleLabel
                .font(.system(size: 15, weight: .regular))
                .lineLimit(1)
                .padding(.leading, 6)
            Spacer()
            selector
            removeButton
        }
        .frame(height: 44)
        .background(
            Rectangle()
                .foregroundStyle(Color.SupportColors.backListRow)
        )
    }
    
    private var paramIcon: Image {
        switch type {
        case .time:
            Image.TaskManagement.DateSelector.time
        case .notifications:
            Image.TaskManagement.DateSelector.remainder
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
            Text(Texts.TaskManagement.DatePicker.remainder)
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
                remainderSelector
            case .notifications:
                remainderSelector
            case .repeating:
                repeatingSelector
            case .endRepeating:
                repeatingSelector
            }
        }
    }
    
    private var remainderSelector: some View {
        Menu {
            ForEach(TaskNotificationsType.allCases.reversed(), id: \.self) { notificationType in
                Button {
                    viewModel.toggleNotificationSelection(for: notificationType)
                } label: {
                    remainderMenuContent(type: notificationType)
                }
            }
            
            Button {
                viewModel.toggleNotificationSelection(for: TaskNotificationsType.none)
            } label: {
                remainderMenuContent(type: TaskNotificationsType.none)
            }
        } label: {
            menuLabel
        }
    }
    
    private func remainderMenuContent(type: TaskNotificationsType) -> some View {
        return HStack {
            Text(type.name)
            Spacer()
            
            if viewModel.selectedNotifications.contains(type) ||
                (viewModel.selectedNotifications.isEmpty && type == .none) {
                Image.TaskManagement.DateSelector.checked
            } else {
                Image.TaskManagement.DateSelector.unchecked
            }
        }
    }
    
    private var repeatingSelector: some View {
        Menu {
            ForEach(TaskRepeatingType.allCases.reversed(), id: \.self) { repeatingType in
                Button {
                    viewModel.toggleRepeatingSelection(for: repeatingType)
                } label: {
                    repeatingMenuContent(type: repeatingType)
                }
            }
            
            Button {
                viewModel.toggleRepeatingSelection(for: TaskRepeatingType.none)
            } label: {
                repeatingMenuContent(type: TaskRepeatingType.none)
            }
        } label: {
            menuLabel
        }
    }
    
    private func repeatingMenuContent(type: TaskRepeatingType) -> some View {
        return HStack {
            Text(type.name)
            Spacer()
            
            if viewModel.selectedRepeating == type {
                Image.TaskManagement.DateSelector.checked
            } else {
                Image.TaskManagement.DateSelector.unchecked
            }
        }
    }
    
    private var menuLabel: some View {
        HStack(spacing: 0) {
            Text(viewModel.menuLabel(for: type))
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .lineLimit(1)
            
            if viewModel.showingMenuIcon(for: type) {
                Image.TaskManagement.DateSelector.menu
                    .resizable()
                    .frame(width: 10, height: 20)
                    .padding(.leading, 9)
                    .padding(.trailing)
            }
        }
    }
    
    private var removeButton: some View {
        HStack {
            if !viewModel.showingMenuIcon(for: type) {
                Button {
                    viewModel.paramRemoveMethod(for: type)
                } label: {
                    Image.TaskManagement.DateSelector.remove
                        .resizable()
                        .frame(width: 12, height: 12)
                }
                .padding(.leading, 9)
                .padding(.trailing)
            }
        }
    }
}

#Preview {
    TaskDateParamRow(type: .repeating,
                     viewModel: TaskManagementViewModel())
}
