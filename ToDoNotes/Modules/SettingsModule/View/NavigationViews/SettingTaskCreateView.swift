//
//  SettingTaskCreateView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/28/25.
//

import SwiftUI

/// A view that allows users to choose how the task creation page is displayed: as a sheet or in full screen.
struct SettingTaskCreateView: View {
    
    /// Provides access to app settings, including task creation preferences.
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    // MARK: - Body
    
    internal var body: some View {
        VStack(spacing: 0) {
            content
                .padding(.top)
                .customNavBarItems(
                    title: Texts.Settings.TaskCreate.title,
                    showBackButton: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    // MARK: - Main Content
    
    /// The main vertical stack that arranges task creation options and description.
    private var content: some View {
        VStack(spacing: 16) {
            taskCreationModeButtons
            descriptionLabel
        }
    }
    
    /// Displays two selectable buttons: "Sheet" and "Full Screen".
    private var taskCreationModeButtons: some View {
        HStack(spacing: 25) {
            sheetModeButton
            fullScreenModeButton
        }
        .padding(32)
        .background(Color.SupportColors.supportButton)
        .clipShape(.rect(cornerRadius: 10))
        
    }
    
    /// Displays a button for selecting sheet mode (popup presentation).
    private var sheetModeButton: some View {
        selectionButton(
            image: Image.Settings.TaskCreate.popup,
            label: Texts.Settings.TaskCreate.popup,
            isSelected: viewModel.taskCreation == .popup
        ) {
            withAnimation(.easeInOut(duration: 0.1)) {
                viewModel.taskCreationChange(to: .popup)
            }
        }
    }
    
    /// Displays a button for selecting full screen mode (fullscreen presentation).
    private var fullScreenModeButton: some View {
        selectionButton(
            image: Image.Settings.TaskCreate.fullScreen,
            label: Texts.Settings.TaskCreate.fullScreen,
            isSelected: viewModel.taskCreation == .fullScreen
        ) {
            withAnimation(.easeInOut(duration: 0.1)) {
                viewModel.taskCreationChange(to: .fullScreen)
            }
        }
    }
    
    /// Displays a description explaining the differences between presentation modes.
    private var descriptionLabel: some View {
        Text(Texts.Settings.TaskCreate.descriptionContent)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(Color.LabelColors.labelPrimary)
            .padding(.horizontal)
    }
    
    // MARK: - Reusable Components
    
    /// Builds a button component for selecting between task creation modes.
    /// - Parameters:
    ///   - image: The image illustrating the mode.
    ///   - label: The title describing the mode.
    ///   - isSelected: A boolean indicating if this mode is currently selected.
    ///   - action: An action to perform when the button is tapped.
    private func selectionButton(image: Image, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            image
                .resizable()
                .scaledToFit()
                .frame(height: 250)
            
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                
                (isSelected ? Image.Selector.selected : Image.Selector.unselected)
                    .resizable()
                    .frame(width: 15, height: 15)
            }
        }
        .onTapGesture {
            action()
        }
    }
}

// MARK: - Preview

#Preview {
    SettingTaskCreateView()
        .environmentObject(SettingsViewModel(notificationsEnabled: true))
}
