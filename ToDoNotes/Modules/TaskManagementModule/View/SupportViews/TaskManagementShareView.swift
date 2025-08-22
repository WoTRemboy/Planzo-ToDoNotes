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
    @State private var viewParam: Bool = false
    /// Indicates whether the task should be editable via the shared link.
    @State private var editParam: Bool = false
    
    // MARK: - Body
    
    internal var body: some View {
        ZStack {
            // Background layer
            Rectangle()
                .foregroundStyle(Color.BackColors.backPrimary)
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
        HStack {
            Text(Texts.TaskManagement.ShareView.title)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelPrimary)
            
            Spacer()
            Button {
                // More button action
            } label: {
                Image.NavigationBar.more
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Share Parameters Form
    
    /// Form containing toggles to configure sharing options (view/edit).
    private var paramsForm: some View {
        VStack(spacing: 3) {
            viewToggle
            editToggle
        }
        .padding([.top, .horizontal])
    }
    
    /// A reusable toggle row for sharing options.
    private var viewToggle: some View {
        ZStack {
            HStack {
                Toggle(isOn: $viewParam) {
                    Text(Texts.TaskManagement.ShareView.view)
                        .font(.system(size: 17, weight: .regular))
                }
            }
            .padding(.horizontal)
            .zIndex(1)
            
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.BackColors.backSecondary)
                .frame(height: 44)
        }
    }
    
    /// A reusable toggle row for edit options.
    private var editToggle: some View {
        ZStack {
            HStack {
                Toggle(isOn: $editParam) {
                    Text(Texts.TaskManagement.ShareView.edit)
                        .font(.system(size: 17, weight: .regular))
                }
            }
            .padding(.horizontal)
            .zIndex(1)
            
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.BackColors.backSecondary)
                .frame(height: 44)
        }
    }
    
    // MARK: - Generate Link Button
    
    /// Button to trigger the generation of a shareable link.
    private var generateLinkButton: some View {
        Button {
            // Action for generate link button
        } label: {
            ZStack {
                HStack {
                    Image.TaskManagement.EditTask.link
                        .resizable()
                        .frame(width: 22, height: 22)
                    
                    Text(Texts.TaskManagement.ShareView.link)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.LabelColors.labelReversed)
                }
                .zIndex(1)
                
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 50)
                    .foregroundStyle(Color.LabelColors.labelDetails)
            }
        }
        .padding(.horizontal)
        .padding(.top, 32)
    }
}

// MARK: - Preview

#Preview {
    TaskManagementShareView()
        .environmentObject(TaskManagementViewModel())
}
