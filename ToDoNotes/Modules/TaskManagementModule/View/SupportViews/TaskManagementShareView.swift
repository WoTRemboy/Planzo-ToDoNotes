//
//  TaskManagementShareView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import SwiftUI

/// A view responsible for displaying the Share Task screen,
/// allowing users to configure sharing parameters and generate a shareable link.
struct TaskManagementShareView: View {
    
    // MARK: - Properties
    
    /// Indicates whether the task should be viewable via the shared link.
    @State private var shareType: ShareAccess = .viewOnly
    
    @State private var isLoading: Bool = false
    @State private var isRotating: Bool = false

    @ObservedObject private var viewModel: TaskManagementViewModel
    
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
                generateLinkButton
            }
            .zIndex(1)
        }
        .popView(isPresented: $viewModel.showingNetworkErrorAlert, onTap: {}, onDismiss: {}) {
            syncErrorAlert
        }
    }
    
    // MARK: - Navigation Bar
    
    /// Top navigation bar with title and more button.
    private var navBar: some View {
        Text(Texts.TaskManagement.ShareView.title)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelPrimary)
        
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    // MARK: - Share Parameters Form
    
    /// Form containing toggles to configure sharing options (view/edit).
    private var paramsForm: some View {
        VStack(spacing: 3) {
            viewButton
            editButton
        }
        .padding([.top, .horizontal])
        .sensoryFeedback(.selection, trigger: shareType)
    }
    
    /// A reusable row for view sharing option.
    private var viewButton: some View {
        paramButton(type: .viewOnly) {
            shareType = .viewOnly
        }
    }
    
    /// A reusable row for edit sharing option.
    private var editButton: some View {
        paramButton(type: .edit) {
            shareType = .edit
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
                
                (shareType == type ? Image.Selector.selected : Image.Selector.unselected)
                    .padding(.trailing)
            }
            
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.SupportColors.supportButton)
            }
        }
        .disabled(isLoading)
    }
    
    // MARK: - Generate Link Button
    
    /// Button to trigger the generation of a shareable link.
    private var generateLinkButton: some View {
        Button {
            generateButtonFunc()
        } label: {
            HStack {
                if isLoading {
                    updatingIcon
                } else {
                    shareIcon
                }
                shareLabel
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.LabelColors.labelReversed)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(Color.LabelColors.labelPrimary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 32)
    }
    
    private var shareIcon: some View {
        Image.TaskManagement.EditTask.link
            .resizable()
            .frame(width: 22, height: 22)
            .transition(.blurReplace)
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
    
    private var shareLabel: Text {
        if isLoading {
            Text(Texts.TaskManagement.ShareView.generating)
        } else {
            Text(Texts.TaskManagement.ShareView.link)
        }
    }
    
    private func generateButtonFunc() {
        let expirationDate = Date().addingTimeInterval(7 * 24 * 3600)
        let isoFormatter = ISO8601DateFormatter()
        let expiresAtString = isoFormatter.string(from: expirationDate)
        withAnimation {
            isLoading = true
        }
        viewModel.handleShareLink(expiresAt: expiresAtString, grantRole: shareType.rawValue) { result in
            switch result {
            case .success():
                onComplete?()
            case .failure(_):
                viewModel.showingNetworkErrorAlert = true
            }
            withAnimation {
                isLoading = false
            }
        }
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

// MARK: - Preview

#Preview {
    TaskManagementShareView(viewModel: TaskManagementViewModel())
}
