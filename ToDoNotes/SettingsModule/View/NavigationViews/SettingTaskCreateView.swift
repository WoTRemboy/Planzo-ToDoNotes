//
//  SettingTaskCreateView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/28/25.
//

import SwiftUI

struct SettingTaskCreateView: View {
    
    @EnvironmentObject private var viewModel: SettingsViewModel
    
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
    
    private var content: some View {
        VStack(spacing: 16) {
            buttons
            descriptionLabel
        }
    }
    
    private var buttons: some View {
        HStack(spacing: 25) {
            sheetPageButton
            fullScreenPageButton
        }
        .padding(32)
        .background(Color.SupportColors.supportButton)
        .clipShape(.rect(cornerRadius: 10))

    }
    
    private var sheetPageButton: some View {
        VStack(spacing: 16) {
            Image.Settings.TaskCreate.popup
                .resizable()
                .scaledToFit()
                .frame(height: 250)
            
            HStack(spacing: 4) {
                Text(Texts.Settings.TaskCreate.popup)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                
                (viewModel.taskCreation == .popup ?
                 Image.Selector.selected :
                    Image.Selector.unselected)
                    .resizable()
                    .frame(width: 15, height: 15)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.taskCreationChange(to: .popup)
            }
        }
    }
    
    private var fullScreenPageButton: some View {
        VStack(spacing: 16) {
            Image.Settings.TaskCreate.fullScreen
                .resizable()
                .scaledToFit()
                .frame(height: 250)
            
            HStack(spacing: 4) {
                Text(Texts.Settings.TaskCreate.fullScreen)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                
                (viewModel.taskCreation == .fullScreen ?
                 Image.Selector.selected :
                    Image.Selector.unselected)
                    .resizable()
                    .frame(width: 15, height: 15)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                viewModel.taskCreationChange(to: .fullScreen)
            }
        }
    }
    
    private var descriptionLabel: some View {
        Text(Texts.Settings.TaskCreate.descriptionContent)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(Color.LabelColors.labelPrimary)
            .padding(.horizontal)
    }
}

#Preview {
    SettingTaskCreateView()
        .environmentObject(SettingsViewModel(notificationsEnabled: true))
}
