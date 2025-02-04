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
    
    init(type: TaskDateParam, viewModel: TaskManagementViewModel) {
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
                timeSelector
            case .notifications:
                remainderSelector
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
                .onChange(of: viewModel.selectedTime) { newValue in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedTimeType = .value(newValue)
                    }
                }
                .labelsHidden()
                .blendMode(.destinationOver)
                .padding(.trailing,
                         viewModel.selectedTimeType == .none ? 16 : 70)
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedTime)
    }
    
    private var remainderSelector: some View {
        menuLabel
            .overlay {
                Menu {
                    // "None" remainder button
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.toggleNotificationSelection(
                                for: TaskNotification.none)
                        }
                    } label: {
                        remainderMenuContent(type: TaskNotification.none)
                    }
                    
                    ForEach(TaskNotification.allCases, id: \.self) { notificationType in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.toggleNotificationSelection(
                                    for: notificationType)
                            }
                        } label: {
                            remainderMenuContent(type: notificationType)
                        }
                    }
                } label: {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                }
                .blendMode(.destinationOver)
                .padding(.trailing,
                         viewModel.notificationsLocal.isEmpty ? 10 : 35)
            }
    }
    
    private func remainderMenuContent(type: TaskNotification) -> some View {
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
                .font(.system(size: 12, weight: .regular))
                .lineLimit(1)
                .foregroundStyle(
                    viewModel.showingMenuIcon(for: type) ?
                    Color.LabelColors.labelSecondary :
                        Color.LabelColors.labelPrimary)
            
            removeButton
        }
        .frame(height: 30)
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
    TaskDateParamRow(type: .endRepeating,
                     viewModel: TaskManagementViewModel())
}
