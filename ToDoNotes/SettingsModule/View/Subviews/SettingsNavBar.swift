//
//  SettingsNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct SettingsNavBar: View {
    internal var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .background(.ultraThinMaterial)
                .blur(radius: 10)
            
            titleLabel
                .padding(.bottom)
        }
        .frame(height: 46.5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
