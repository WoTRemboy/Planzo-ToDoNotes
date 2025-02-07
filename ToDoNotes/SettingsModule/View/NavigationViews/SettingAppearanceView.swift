//
//  SettingAppearanceView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

struct SettingAppearanceView: View {
    
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    internal var body: some View {
        VStack(spacing: 0) {
            SettingAppearanceNavBar {
                viewModel.toggleShowingAppearance()
            }
            themePicker
                .scrollDisabled(true)
        }
    }
    
    private var themePicker: some View {
        Form {
            ForEach(Theme.allCases, id: \.self) { theme in
                Button {
                    viewModel.changeTheme(theme: theme)
                } label: {
                    SettingFormRow(
                        title: theme.name,
                        check: theme == viewModel.userTheme)
                }
            }
            .listRowBackground(Color.SupportColors.backListRow)
        }
        .padding(.horizontal, -10)
        .background(Color.BackColors.backDefault)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    SettingAppearanceView()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}
