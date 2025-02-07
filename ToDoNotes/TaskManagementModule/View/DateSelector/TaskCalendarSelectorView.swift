//
//  TaskCalendarSelectorView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/28/25.
//

import SwiftUI

struct TaskCalendarSelectorView: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    init(viewModel: TaskManagementViewModel) {
        self.viewModel = viewModel
    }
    
    internal var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    calendarSection
                    separator
                    paramsForm
                }
                .scrollIndicators(.hidden)
                .padding(.bottom, hasNotch() ? 100 : 80)

                removeButton
                    .zIndex(1)
            }
            .edgesIgnoringSafeArea(.bottom)
            
            .navigationTitle(Texts.TaskManagement.DatePicker.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    toolBarButtonCancel
                }
                ToolbarItem(placement: .topBarTrailing) {
                    toolBarButtonDone
                }
            }
            .onAppear {
                viewModel.readNotificationStatus()
            }
            .alert(isPresented: $viewModel.showingNotificationAlert) {
                if viewModel.notificationsStatus == .disabled {
                    disabledAlert
                } else {
                    prohibitedAlert
                }
            }
        }
    }
    
    private var prohibitedAlert: Alert {
        Alert(
            title: Text(Texts.Settings.Notification.prohibitedTitle),
            message: Text(Texts.Settings.Notification.alertContent),
            primaryButton: .default(Text(Texts.Settings.title)) {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            },
            secondaryButton: .cancel(Text(Texts.Settings.cancel))
        )
    }
    
    private var disabledAlert: Alert {
        Alert(
            title: Text(Texts.Settings.Notification.disableTitle),
            message: Text(Texts.Settings.Notification.alertContent),
            dismissButton: .cancel(Text(Texts.Settings.ok))
        )
    }
    
    private var toolBarButtonCancel: some View {
        Button {
            viewModel.toggleDatePicker()
        } label: {
            Text(Texts.TaskManagement.DatePicker.cancel)
                .font(.system(size: 17, weight: .regular))
        }
    }
    
    private var toolBarButtonDone: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.saveTaskDateParams()
                viewModel.toggleDatePicker()
            }
        } label: {
            Text(Texts.TaskManagement.DatePicker.done)
                .font(.system(size: 17, weight: .semibold))
        }
    }
    
    private var calendarSection: some View {
        TaskCustomCalendar(viewModel: viewModel)
    }
    
    private var separator: some View {
        Divider()
            .background(Color.LabelColors.labelTertiary)
            .frame(height: 0.36)
            .padding([.top, .horizontal])
    }
    
    private var paramsForm: some View {
        VStack(spacing: 0) {
            TaskDateParamRow(type: .time,
                             viewModel: viewModel)
            TaskDateParamRow(type: .notifications,
                             viewModel: viewModel)
            TaskDateParamRow(type: .repeating,
                             viewModel: viewModel)
            
            if viewModel.selectedRepeating != .none {
                TaskDateParamRow(type: .endRepeating,
                                 viewModel: viewModel)
            }
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding()
    }
    
    private var removeButton: some View {
        ZStack(alignment: hasNotch() ? .top : .center) {
            Rectangle()
                .fill(Color.BackColors.backDefault)
                .frame(maxWidth: .infinity, maxHeight: hasNotch() ? 100 : 80)
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.allParamRemoveMethod()
                }
            } label: {
                Text(Texts.TaskManagement.DatePicker.removeAll)
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .minimumScaleFactor(0.4)
            
            .foregroundStyle(Color.ButtonColors.remove)
            .tint(Color.ButtonColors.remove)
            .buttonStyle(.bordered)
            .padding()
        }
    }
}

#Preview {
    TaskCalendarSelectorView(viewModel: TaskManagementViewModel())
}
