//
//  SettingsNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct SettingsNavBar: View {
    internal var body: some View {
        titleLabel
            .frame(height: 46.5)
    }
    
    private var titleLabel: some View {
        Text(Texts.Settings.title)
            .font(.system(size: 20, weight: .regular))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
    }
}

#Preview {
    SettingsNavBar()
        .environmentObject(SettingsViewModel())
}
