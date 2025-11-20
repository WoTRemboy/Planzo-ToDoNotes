//
//  SharingAccessManageView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 19/11/2025.
//

import SwiftUI
import OSLog

struct SharingAccessManageView: View {

    @ObservedObject private var viewModel: TaskManagementViewModel
    
    @State private var isRotating: Bool = false
    
    private let onComplete: (() -> Void)?
    
    init(viewModel: TaskManagementViewModel, onComplete: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onComplete = onComplete
    }
    
    // MARK: - Body
    
    internal var body: some View {
        ZStack {
            // Background layer
            Rectangle()
                .foregroundStyle(Color.BackColors.backSheet)
                .ignoresSafeArea()
            
            // Main content
            VStack {
                navBar
                paramsForm
                actionButtons
            }
            .padding(.top)
            .zIndex(1)
            .onAppear {
                if let member = viewModel.selectedMember, let role = ShareAccess(rawValue: member.role) {
                    if viewModel.selectedShareType != role {
                        viewModel.selectedShareType = role
                    }
                } else if viewModel.selectedShareType != .viewOnly {
                    viewModel.selectedShareType = .viewOnly
                }
            }
        }
        .popView(isPresented: $viewModel.showingRemoveMemberAlert, onTap: {}, onDismiss: {}) {
            removeMemberAlert
        }
        .popView(isPresented: $viewModel.showingNetworkErrorAlert, onTap: {}, onDismiss: {}) {
            syncErrorAlert
        }
    }
    
    // MARK: - Navigation Bar
    
    /// Top navigation bar with title and more button.
    private var navBar: some View {
        let memberName = viewModel.selectedMember?.id ?? Texts.TaskManagement.SharingAccess.user
        
        return Text("\(Texts.TaskManagement.ShareView.accessFor) \(String(memberName.prefix(8)))")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelPrimary)
            .lineLimit(1)
        
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    // MARK: - Share Parameters Form
    
    /// Form containing toggles to configure sharing options (view/edit).
    private var paramsForm: some View {
        VStack(spacing: 3) {
            viewButton
            editButton
            closeAccessButton
        }
        .padding([.top, .horizontal])
        .sensoryFeedback(.selection, trigger: viewModel.selectedShareType)
    }
    
    /// A reusable row for view sharing option.
    private var viewButton: some View {
        paramButton(type: .viewOnly) {
            viewModel.selectedShareType = .viewOnly
        }
    }
    
    /// A reusable row for edit sharing option.
    private var editButton: some View {
        paramButton(type: .edit) {
            viewModel.selectedShareType = .edit
        }
    }
    
    private var closeAccessButton: some View {
        paramButton(type: .closed) {
            viewModel.selectedShareType = .closed
        }
    }
    
    private func paramButton(type: ShareAccess, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Text(type.name)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                
                (viewModel.selectedShareType == type ? Image.Selector.selected : Image.Selector.unselected)
                    .padding(.trailing)
            }
            
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.SupportColors.supportButton)
            }
        }
        .disabled(viewModel.isUpdatingMemberRole)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 4) {
            secondaryButton
            saveButton
        }
        .padding(.horizontal)
        .padding(.top, 32)
    }
    
    /// Button to trigger the generation of a shareable link.
    private var saveButton: some View {
        Button {
            if viewModel.selectedShareType == .closed {
                viewModel.toggleShowingRemoveMemberAlert()
            } else {
                viewModel.updateMemberRole(newRole: viewModel.selectedShareType) {
                    withAnimation {
                        (onComplete ?? {})()
                    }
                }
            }
        } label: {
            HStack {
                if viewModel.isUpdatingMemberRole {
                    updatingIcon
                }
                Text(Texts.TaskManagement.ShareView.save)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.LabelColors.labelReversed)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(Color.LabelColors.labelPrimary)
            }
            .animation(.easeInOut, value: viewModel.isUpdatingMemberRole)
        }
        .disabled(viewModel.isUpdatingMemberRole)
    }
    
    private var updatingIcon: some View {
        Image.TaskManagement.EditTask.generate
            .resizable()
            .frame(width: 22, height: 22)
            .rotationEffect(Angle.degrees(isRotating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isRotating)
            .onAppear {
                isRotating = true
            }
            .onDisappear {
                isRotating = false
            }
            .transition(.scale)
    }
    
    private var secondaryButton: some View {
        Button {
            withAnimation {
                viewModel.selectedMember = nil
            }
        } label: {
            Text(Texts.TaskManagement.ShareView.cancel)
                .font(.system(size: 17, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.clear)
                .foregroundColor(Color.LabelColors.labelPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.LabelColors.labelDetails, lineWidth: 1)
                )
        }
    }
    
    private var removeMemberAlert: some View {
        let memberName = viewModel.selectedMember?.id ?? Texts.TaskManagement.SharingAccess.user
        return CustomAlertView(
            title: "\(Texts.TaskManagement.ShareView.RemoveMemberAlert.title) \(String(memberName.prefix(8)))",
            message: Texts.TaskManagement.ShareView.RemoveMemberAlert.message,
            primaryButtonTitle: Texts.TaskManagement.ShareView.RemoveMemberAlert.accept,
            primaryAction: {
                if let member = viewModel.selectedMember {
                    viewModel.deleteMember(member) {
                        withAnimation {
                            (onComplete ?? {})()
                        }
                    }
                }
                viewModel.toggleShowingRemoveMemberAlert()
            },
            secondaryButtonTitle: Texts.Settings.Sync.Retry.cancel,
            secondaryAction: {
                viewModel.toggleShowingRemoveMemberAlert()
            })
    }
    
    private var syncErrorAlert: some View {
        CustomAlertView(
            title: Texts.Settings.Sync.Retry.title,
            message: Texts.Settings.Sync.Retry.content,
            primaryButtonTitle: Texts.Settings.Sync.Retry.cancel,
            primaryAction: {
                viewModel.showingNetworkErrorAlert.toggle()
            })
    }
}

#Preview {
    SharingAccessManageView(viewModel: TaskManagementViewModel())
}
