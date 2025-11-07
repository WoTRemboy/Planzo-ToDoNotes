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
    }
    
    // MARK: - Generate Link Button
    
    /// Button to trigger the generation of a shareable link.
    private var generateLinkButton: some View {
        Button {
            let expirationDate = Date().addingTimeInterval(7 * 24 * 3600)
            let isoFormatter = ISO8601DateFormatter()
            let expiresAtString = isoFormatter.string(from: expirationDate)
            viewModel.handleShareLink(expiresAt: expiresAtString) {
                onComplete?()
            }
        } label: {
            HStack {
                Image.TaskManagement.EditTask.link
                    .resizable()
                    .frame(width: 22, height: 22)
                
                Text(Texts.TaskManagement.ShareView.link)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.LabelColors.labelReversed)
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
}

// MARK: - Preview

#Preview {
    TaskManagementShareView(viewModel: TaskManagementViewModel())
}
