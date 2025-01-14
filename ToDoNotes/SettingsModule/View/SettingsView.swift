//
//  SettingsView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    internal var body: some View {
        ZStack {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            SettingsNavBar()
            Text("Вкладка Настройки")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var aboutAppSection: some View {
        Section(Texts.Settings.About.title) {
            AboutAppView(name: viewModel.appName,
                         version: viewModel.appVersion)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}
