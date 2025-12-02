//
//  TaskManagementNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

/// Navigation bar for the task creation/editing screen.
struct TaskManagementNavBar: View {
    
    // MARK: - Properties
    
    /// View model controlling the current task state.
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    @EnvironmentObject private var authService: AuthNetworkService
    
    /// The task entity being edited/created.
    private let entity: TaskEntity?
    /// Closure triggered when duplicating a task.
    private let onDuplicate: () -> Void
    /// Closure triggered when dismissing the task editor.
    private let onDismiss: () -> Void
    
    // MARK: - Initialization
    
    /// Creates a new `TaskManagementNavBar`.
    /// - Parameters:
    ///   - viewModel: The associated `TaskManagementViewModel`.
    ///   - entity: The task entity being managed/created.
    ///   - onDuplicate: Closure executed when duplicating a task.
    ///   - onDismiss: Closure executed when dismissing the view.
    init(viewModel: TaskManagementViewModel,
         entity: TaskEntity?,
         onDuplicate: @escaping () -> Void,
         onDismiss: @escaping () -> Void) {
        self.entity = entity
        self.viewModel = viewModel
        self.onDuplicate = onDuplicate
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                // Background color and shadow for the navigation bar
                Color.SupportColors.supportNavBar
                    .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        backButton  // Back button to dismiss the view
                        titleLabel  // Title showing today's date
                        if entity != nil, authService.isAuthorized, viewModel.isTaskOwner {
                            shareButton
                        }
                        moreButton  // More options button (menu with actions)
                    }
                }
                .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    // MARK: - Components
    
    /// Back button for dismissing the task management view.
    private var backButton: some View {
        Button {
            onDismiss()
        } label: {
            Image.NavigationBar.hide
                .resizable()
                .frame(width: 24, height: 24)
        }
        .padding(.leading)
    }
    
    /// Title label showing today's date and weekday.
    private var titleLabel: some View {
        HStack(spacing: 4) {
            Text(Texts.TaskManagement.today)
                .font(.system(size: 22, weight: .bold))
                .padding(.leading)
            
            Text(viewModel.todayDate.shortDate)
                .font(.system(size: 22, weight: .bold))
            
            Text(viewModel.todayDate.shortWeekday)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelSecondary)
                .padding(.trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var shareButton: some View {
        Button {
            viewModel.setSharingTask(to: entity)
        } label: {
            Image.NavigationBar.share
                .resizable()
                .frame(width: 24, height: 24)
        }
        .padding(.trailing)
        .disabled(!viewModel.accessToEdit)
    }
    
    /// The menu button for additional task actions (important, pinned, delete, duplicate).
    private var moreButton: some View {
        Menu {
            if entity?.role != ShareAccess.viewOnly.rawValue {
                ControlGroup {
                    importanceButton
                    pinnedButton
                    if entity != nil {
                        deleteButton
                    }
                }
                .controlGroupStyle(.compactMenu)
            } else {
                if entity != nil {
                    deleteButton
                }
            }
            
            if !viewModel.shareMembers.isEmpty, viewModel.currentRole == .owner {
                shareSettingsButton
            }
            if entity != nil {
                duplicateButton
            }
            if !viewModel.shareMembers.isEmpty,
                viewModel.currentRole == .owner {
                closeSharingButton
            }
        } label: {
            Image.NavigationBar.more
                .resizable()
                .frame(width: 24, height: 24)
        }
        .padding(.trailing)
    }
    
    // MARK: - Menu Buttons
    
    /// Toggles importance for the task.
    private var importanceButton: some View {
        Button {
            viewModel.toggleImportanceCheck()
            Toast.shared.present(
                title: viewModel.importance
                ? Texts.Toasts.importantOn
                : Texts.Toasts.importantOff
            )
        } label: {
            Label {
                Text(viewModel.importance
                     ? Texts.TaskManagement.ContextMenu.importantDeselect
                     : Texts.TaskManagement.ContextMenu.important)
            } icon: {
                viewModel.importance
                ? Image.TaskManagement.EditTask.Menu.importantDeselect
                : Image.TaskManagement.EditTask.Menu.importantSelect
                    .renderingMode(.template)
            }
        }
    }
    
    /// Toggles pinned status for the task.
    private var pinnedButton: some View {
        Button {
            viewModel.togglePinnedCheck()
            Toast.shared.present(
                title: viewModel.pinned
                ? Texts.Toasts.pinnedOn
                : Texts.Toasts.pinnedOff
            )
        } label: {
            Label {
                Text(viewModel.pinned
                     ? Texts.TaskManagement.ContextMenu.unpin
                     : Texts.TaskManagement.ContextMenu.pin)
            } icon: {
                viewModel.pinned
                ? Image.TaskManagement.EditTask.Menu.pinnedDeselect
                : Image.TaskManagement.EditTask.Menu.pinnedSelect
                    .renderingMode(.template)
            }
        }
    }
    
    /// Deletes the current task.
    private var deleteButton: some View {
        Button(role: .destructive) {
            if let task = entity, let role = task.role, role != ShareAccess.owner.rawValue {
                viewModel.requestConfirmSharedDelete(for: task)
            } else {
                viewModel.toggleRemoved()
                onDismiss()
                Toast.shared.present(title: Texts.Toasts.removed)
            }
        } label: {
            Label {
                Text(Texts.TaskManagement.ContextMenu.delete)
            } icon: {
                Image.TaskManagement.EditTask.Menu.trash
                    .renderingMode(.template)
            }
        }
    }
    
    /// Duplicates the current task.
    private var duplicateButton: some View {
        Button {
            onDuplicate()
            onDismiss()
        } label: {
            Label {
                Text(Texts.TaskManagement.ContextMenu.dublicate)
            } icon: {
                Image.TaskManagement.EditTask.Menu.copy
                    .renderingMode(.template)
            }
        }
    }
    
    private var shareSettingsButton: some View {
        CustomNavLink(
            destination: SharingAccessView(viewModel: viewModel)) {
                    Label {
                        Text(Texts.TaskManagement.SharingAccess.shareSetting)
                    } icon: {
                        Image.TaskManagement.EditTask.Menu.shareSettings
                            .renderingMode(.template)
                    }
                }
    }
    
    private var closeSharingButton: some View {
        Button {
            viewModel.toggleShowingStopSharingAlert()
        } label: {
            Label {
                Text(Texts.TaskManagement.SharingAccess.endSharing)
            } icon: {
                Image.TaskManagement.EditTask.Menu.closeSharing
                    .renderingMode(.template)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TaskManagementNavBar(
        viewModel: TaskManagementViewModel(),
        entity: PreviewData.taskItem,
        onDuplicate: {},
        onDismiss: {})
    .environmentObject(AuthNetworkService())
}
