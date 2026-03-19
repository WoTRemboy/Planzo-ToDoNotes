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

    @Environment(\.dismiss) private var dismiss
    
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
            
            doneButton
                .zIndex(1)
        }
        .presentationDragIndicator(.visible)
        
        .onAppear {
            viewModel.captureDateParamsSnapshot()
            viewModel.readNotificationStatus()
        }
        .popView(isPresented: $viewModel.showingNotificationAlert, onTap: {}, onDismiss: {}) {
            if viewModel.notificationsStatus == .disabled {
                disabledAlert
            } else {
                prohibitedAlert
            }
        }
    }
    
    // MARK: - Subviews
    
    /// The header containing Title label.
    private var header: some View {
        Text(Texts.TaskManagement.DatePicker.title)
            .font(.system(size: 20, weight: .medium))
            .frame(maxWidth: .infinity)
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
    
    /// Cancel button that discards changes and closes the sheet.
    private var cancelButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.cancelTaskDateParams()
                viewModel.toggleDatePicker()
                dismiss()
            }
        } label: {
            Text(Texts.TaskManagement.DatePicker.cancel)
                .font(.system(size: 17, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: 50)
                .minimumScaleFactor(0.5)
                .background(Color.clear)
                .foregroundColor(Color.LabelColors.labelPrimary)
                .modifier(SystemRowCornerModifier())
                .overlay {
                    if #available(iOS 26.0, *) {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.LabelColors.labelDetails, lineWidth: 1)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.LabelColors.labelDetails, lineWidth: 1)
                    }
                }
        }
    }

    /// Done button that saves date settings and closes the view.
    private var toolBarButtonDone: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.saveTaskDateParams()
                viewModel.toggleDatePicker()
                dismiss()
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
        .modifier(SystemRowCornerModifier())
        .padding()
    }
    
    private var doneButton: some View {
        HStack(spacing: 12) {
            cancelButton
                .frame(width: 120, height: 50)

            Button {
                viewModel.saveTaskDateParams()
                viewModel.toggleDatePicker()
                dismiss()
            } label: {
                Text(Texts.TaskManagement.DatePicker.done)
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.LabelColors.labelReversed)
                    .modifier(DoneButtonLegacyBackground())
            }
            .interactiveTintGlassIfAvailable(color: Color.LabelColors.labelPrimary)
            .frame(height: 50)
            .minimumScaleFactor(0.4)
        }
        .padding(.horizontal)
        .padding(.bottom)
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

private struct DoneButtonLegacyBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content
                .background(Color.LabelColors.labelPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Preview

#Preview {
    TaskCalendarSelectorView(
        entity: TaskEntity(),
        viewModel: TaskManagementViewModel())
}
