//
//  TaskCalendarSelectorView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/28/25.
//

import SwiftUI

/// A view for selecting the date, time, and notification settings for a task.
struct TaskCalendarSelectorView: View {
    
    // MARK: - Properties
    
    /// View model for managing task data and date parameters.
    @ObservedObject private var viewModel: TaskManagementViewModel
    /// Namespace used for animations between views.
    @Namespace private var namespace
    
    /// Optional task entity being edited (nil for new tasks).
    private let entity: TaskEntity?
    
    // MARK: - Initialization
        
    /// Initializes the date selector view.
    /// - Parameters:
    ///   - entity: The task entity to edit, if not nil.
    ///   - viewModel: The view model handling task data.
    init(entity: TaskEntity?,
         viewModel: TaskManagementViewModel) {
        self.entity = entity
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    /// Main body of the view.
    internal var body: some View {
        ZStack(alignment: .bottom) {
            // The background color of the entire view.
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
    
    // MARK: - Subviews
    
    /// The header containing Cancel, Title, and Done buttons.
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
    
    // MARK: - Alerts
    
    /// Alert shown when notifications are prohibited by system settings.
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
    
    /// Alert shown when notifications are disabled manually by the user.
    private var disabledAlert: some View {
        CustomAlertView(
            title: Texts.Settings.Notification.disabledTitle,
            message: Texts.Settings.Notification.disabledContent,
            primaryButtonTitle: Texts.Settings.ok,
            primaryAction: viewModel.toggleShowingNotificationAlert)
    }
    
    // MARK: - Buttons
    
    /// An invisible cancel button used for layout balance in the header.
    private var toolBarButtonCancel: some View {
        Rectangle()
            .foregroundStyle(Color.clear)
            .frame(width: 24, height: 24)
    }
    
    /// Done button that saves date settings and closes the view.
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
    
    /// Calendar section for picking a date and optional time.
    private var calendarSection: some View {
        TaskCustomCalendar(viewModel: viewModel, namespace: namespace)
            .padding(.top)
    }
    
    /// Form for selecting additional date parameters such as notifications.
    private var paramsForm: some View {
        VStack(spacing: 0) {
            TaskDateParamRow(type: .time,
                             isLast: false,
                             viewModel: viewModel)
            TaskDateParamRow(type: .notifications,
                             isLast: true,
                             viewModel: viewModel)
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding()
    }
    
    /// Button to clear all selected parameters (date, time, notifications).
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

// MARK: - Preview

#Preview {
    TaskCalendarSelectorView(
        entity: TaskEntity(),
        viewModel: TaskManagementViewModel())
}
