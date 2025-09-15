//
//  SettingAboutPageView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/28/25.
//

import SwiftUI

/// A screen displaying information about the application, including name, version, and copyright.
struct SettingAboutPageView: View {
    
    /// Provides access to app metadata such as name, version, and build number.
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    // MARK: - Body
    
    internal var body: some View {
        VStack(spacing: 0) {
            content
                .padding(.top, 100)
                .customNavBarItems(
                    title: Texts.Settings.About.title,
                    showBackButton: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    // MARK: - Main Content
    
    /// The main content stack containing the app logo, name, version, and copyright.
    private var content: some View {
        VStack(spacing: 0) {
            appLogo
            appName
                .padding(.top, 24)
            version
                .padding(.top, 50)
        }
    }
    
    /// Displays the app logo image.
    private var appLogo: some View {
        Image.Settings.aboutLogo
            .resizable()
            .frame(width: 185, height: 185)
            .clipShape(
                RoundedRectangle(cornerRadius: 40)
            )
    }
    
    /// Displays the app name.
    private var appName: some View {
        Text(viewModel.appName)
            .font(.system(size: 25, weight: .bold))
            .foregroundStyle(Color.LabelColors.labelPrimary)
    }
    
    /// Displays the app version and copyright.
    private var version: some View {
        VStack(spacing: 8) {
            Text("\(Texts.Settings.About.version) \(viewModel.appVersion) (\(viewModel.buildVersion))")
                .font(.system(size: 18, weight: .medium))
            
            Text(Texts.Settings.About.copyright)
                .font(.system(size: 14, weight: .regular))
        }
    }
}

// MARK: - Preview

#Preview {
    SettingAboutPageView()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}
