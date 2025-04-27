//
//  SettingsNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

/// A custom navigation bar used in the Settings screen,
/// providing consistent style with shadow, background color, and title.
struct SettingsNavBar: View {
    
    // MARK: - Body
    
    internal var body: some View {
        GeometryReader { proxy in
            // Safe area inset to account for notches or status bar
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                navBarBackground
                titleLabel
                    .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    // MARK: - Components
    
    /// The background color and shadow for the navigation bar.
    private var navBarBackground: some View {
        Color.SupportColors.supportNavBar
            .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
    }
    
    /// The title label of the navigation bar.
    private var titleLabel: some View {
        Text(Texts.Settings.title)
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
    }
}

// MARK: - Preview

#Preview {
    SettingsNavBar()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}
