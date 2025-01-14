//
//  SettingAppearanceNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

struct SettingAppearanceNavBar: View {
    
    private var onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack {
                backButton
                titleLabel
                placeholder
            }
        }
        .frame(height: 46.5)
    }
    
    private var backButton: some View {
        Button {
            onDismiss()
        } label: {
            Image.NavigationBar.back
                .resizable()
                .frame(width: 22, height: 22)
        }
        .padding(.leading)
    }
    
    private var titleLabel: some View {
        Text(Texts.Settings.Appearance.title)
            .font(.system(size: 17, weight: .regular))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal)
    }
    
    private var placeholder: some View {
        Rectangle()
            .foregroundStyle(Color.clear)
            .frame(width: 22, height: 22)
            .padding(.trailing)
    }
}

#Preview {
    SettingAppearanceNavBar() {}
}
