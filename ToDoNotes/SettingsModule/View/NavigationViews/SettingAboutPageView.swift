//
//  SettingAboutPageView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/28/25.
//

import SwiftUI

struct SettingAboutPageView: View {
    
    @EnvironmentObject private var viewModel: SettingsViewModel
    
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
    
    private var content: some View {
        VStack(spacing: 0) {
            Image.Settings.aboutLogo
                .resizable()
                .frame(width: 185, height: 185)
                .clipShape(.rect(cornerRadius: 16))
            
            Text(viewModel.appName)
                .font(.system(size: 25, weight: .bold))
                .padding(.top)
            
            version
                .padding(.top, 50)
        }
    }
    
    private var version: some View {
        VStack(spacing: 8) {
            Text("\(Texts.Settings.About.version) \(viewModel.appVersion)")
                .font(.system(size: 18, weight: .medium))
            
            Text(Texts.Settings.About.copyright)
                .font(.system(size: 14, weight: .regular))
        }
    }
}

#Preview {
    SettingAboutPageView()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}
