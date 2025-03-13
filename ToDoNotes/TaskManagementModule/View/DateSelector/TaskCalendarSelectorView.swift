//
//  TaskCalendarSelectorView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/28/25.
//

import SwiftUI

struct TaskCalendarSelectorView: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    @Namespace private var namespace
    
    private let entity: TaskEntity?
    
    init(entity: TaskEntity?,
         viewModel: TaskManagementViewModel) {
        self.entity = entity
        self.viewModel = viewModel
    }
    
    internal var body: some View {
        ZStack(alignment: .bottom) {
            Color.BackColors.backSheet
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                calendarSection
                paramsForm
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            removeButton
                .zIndex(1)
        }
        .presentationDragIndicator(.visible)
        
        .onAppear {
            viewModel.readNotificationStatus()
        }
        .popView(isPresented: $viewModel.showingNotificationAlert, onDismiss: {}) {
            if viewModel.notificationsStatus == .disabled {
                disabledAlert
            } else {
                prohibitedAlert
            }
        }
    }
    
    private var header: some View {
        HStack {
            toolBarButtonCancel
            Spacer()
            Text(Texts.TaskManagement.DatePicker.title)
                .font(.system(size: 20, weight: .medium))
            
            Spacer()
            toolBarButtonDone
        }
        .padding([.horizontal, .top], 24)
    }
    
    private var prohibitedAlert: some View {
        CustomAlertView(
            title: Texts.Settings.Notification.prohibitedTitle,
            message: Texts.Settings.Notification.prohibitedContent,
            primaryButtonTitle: Texts.Settings.title,
            primaryAction: {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            },
            secondaryButtonTitle: Texts.Settings.cancel,
            secondaryAction: viewModel.toggleShowingNotificationAlert)
    }
    
    private var disabledAlert: some View {
        CustomAlertView(
            title: Texts.Settings.Notification.disabledTitle,
            message: Texts.Settings.Notification.disabledContent,
            primaryButtonTitle: Texts.Settings.ok,
            primaryAction: viewModel.toggleShowingNotificationAlert)
    }
    
    private var toolBarButtonCancel: some View {
        Button {
            viewModel.toggleDatePicker()
        } label: {
            Image.TaskManagement.DateSelector.close
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
    
    private var toolBarButtonDone: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.saveTaskDateParams()
                viewModel.toggleDatePicker()
            }
        } label: {
            Image.TaskManagement.DateSelector.confirm
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
    
    private var calendarSection: some View {
        TaskCustomCalendar(viewModel: viewModel,
                           namespace: namespace)
        .padding(.top)
    }
    
    private var paramsForm: some View {
        VStack(spacing: 0) {
            TaskDateParamRow(type: .time,
                             isLast: false,
                             viewModel: viewModel)
            TaskDateParamRow(type: .notifications,
                             isLast: true,
                             viewModel: viewModel)
//            TaskDateParamRow(type: .repeating,
//                             viewModel: viewModel)
            
//            if viewModel.selectedRepeating != .none {
//                TaskDateParamRow(type: .endRepeating,
//                                 viewModel: viewModel)
//            }
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding()
    }
    
    private var removeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.allParamRemoveMethod()
            }
        } label: {
            Text(Texts.TaskManagement.DatePicker.removeAll)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.ButtonColors.remove)
        }
        .padding(.bottom)
    }
}

#Preview {
    TaskCalendarSelectorView(
        entity: TaskEntity(),
        viewModel: TaskManagementViewModel())
}
