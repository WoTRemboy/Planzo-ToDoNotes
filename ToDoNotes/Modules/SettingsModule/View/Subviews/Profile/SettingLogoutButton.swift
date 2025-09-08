//
//  SettingLogoutButton.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 08/09/2025.
//

import SwiftUI

struct SettingLogoutButton: View {
    
    // MARK: - Body
    
    internal var body: some View {
        HStack {
            image
            label
        }
        
        .padding(.horizontal, 14)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .background(Color.SupportColors.supportButton)
    }
    
    // MARK: - Components
    
    private var image: some View {
        Image.Settings.logout
            .resizable()
            .scaledToFit()
            .frame(width: 26, height: 26)
    }
    
    /// Label view displaying the optional image and title on the left.
    private var label: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(Texts.Authorization.logout)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelLogout)
                .lineLimit(1)
        }
    }
}

#Preview {
    SettingLogoutButton()
}
