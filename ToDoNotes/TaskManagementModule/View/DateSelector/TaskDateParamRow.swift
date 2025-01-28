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
        Menu {
            ForEach(TaskNotificationsType.allCases.reversed(), id: \.self) { notificationType in
                Button {
                    viewModel.toggleNotificationSelection(for: notificationType)
                } label: {
                    menuContent(type: notificationType)
                }
            }
            
            Button {
                viewModel.toggleNotificationSelection(for: TaskNotificationsType.none)
            } label: {
                menuContent(type: TaskNotificationsType.none)
            }
        } label: {
            menuLabel
        }
    }
    
    private func menuContent(type: TaskNotificationsType) -> some View {
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
    
    private var menuLabel: some View {
        HStack {
            Text(viewModel.selectedNotificationDescription)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .lineLimit(1)
            
            if viewModel.selectedNotifications.isEmpty {
                Image.TaskManagement.DateSelector.menu
                    .padding(.leading, 9)
                    .padding(.trailing)
            }
        }
    }
    
    private var removeButton: some View {
        HStack {
            if !viewModel.selectedNotifications.isEmpty {
                Button {
                    viewModel.selectedNotifications.removeAll()
                } label: {
                    Image.TaskManagement.DateSelector.remove
                }
                .padding(.leading, 9)
                .padding(.trailing)
            }
        }
    }
}

#Preview {
    TaskDateParamRow(type: .notifications, viewModel: TaskManagementViewModel())
}
