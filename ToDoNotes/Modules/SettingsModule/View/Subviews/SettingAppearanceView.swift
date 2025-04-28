//
//  SettingAppearanceView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/3/25.
//

import SwiftUI

/// A view that allows the user to select and apply an appearance theme (Light, Dark, or System Default).
struct SettingAppearanceView: View {
    
    // MARK: - Properties
    
    /// The current color scheme of the app.
    @Environment(\.colorScheme) private var scheme
    /// Access to the settings view model.
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    /// The currently selected theme during selection (local state).
    @State private var selectedTheme: Theme = .systemDefault
    
    // MARK: - Body
        
    internal var body: some View {
        VStack(spacing: 20) {
            title
            themeSelector
            actionButtons
        }
        .frame(width: 320)
        
        .background(Color.BackColors.backSecondary)
        .cornerRadius(12)
        .shadow(radius: 10)
        
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            selectedTheme = viewModel.userTheme
        }
    }
    
    // MARK: - Components
    
    /// Title for the appearance selection sheet.
    private var title: some View {
        Text(Texts.Settings.Appearance.title)
            .font(.system(size: 17, weight: .semibold))
            .padding(.top, 12)
    }
    
    /// List of available themes for selection.
    private var themeSelector: some View {
        VStack(spacing: 16) {
            ForEach(Theme.allCases, id: \.self) { theme in
                Button {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        selectedTheme = theme
                    }
                } label: {
                    selectorRow(title: theme.name,
                                isSelected: theme == selectedTheme)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    /// A single row in the theme selector.
    /// - Parameters:
    ///   - title: The name of the theme.
    ///   - isSelected: Whether the current theme is selected.
    @ViewBuilder
    private func selectorRow(title: String, isSelected: Bool) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .regular))
            Spacer()
            
            (isSelected ? Image.Selector.selected :
               Image.Selector.unselected)
               .resizable()
               .frame(width: 20, height: 20)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 16)
    }
    
    // MARK: - Action Buttons
    
    /// Buttons to accept or cancel the theme selection.
    private var actionButtons: some View {
        HStack(spacing: 4) {
            cancelButton
            acceptButton
        }
        .padding([.horizontal, .bottom], 6)
    }
    
    /// Button to cancel the selection and dismiss the sheet.
    private var cancelButton: some View {
        Button {
            viewModel.toggleShowingAppearance()
        } label: {
            ZStack {
                Color.clear
                
                Text(Texts.Settings.Appearance.cancel)
                    .font(.system(size: 17, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.LabelColors.labelPrimary)
            }
            .clipShape(.rect(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.LabelColors.labelDetails, lineWidth: 1)
            )
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
    
    /// Button to confirm the selection and apply the selected theme.
    private var acceptButton: some View {
        Button {
            viewModel.toggleShowingAppearance()
            viewModel.changeTheme(theme: selectedTheme)
        } label: {
            ZStack {
                Color.LabelColors.labelPrimary
                
                Text(Texts.Settings.Appearance.accept)
                    .font(.system(size: 17, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.LabelColors.labelReversed)
            }
            .clipShape(.rect(cornerRadius: 10))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    SettingAppearanceView()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}
