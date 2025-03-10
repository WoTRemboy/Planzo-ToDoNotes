//
//  SettingsNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct SettingsNavBar: View {
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                Color.BackColors.backDefault
                    .shadow(color: Color.ShadowColors.shadowDefault, radius: 15, x: 0, y: 5)
                
                titleLabel
                    .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    private var titleLabel: some View {
        Text(Texts.Settings.title)
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
    }
}

#Preview {
    SettingsNavBar()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}
