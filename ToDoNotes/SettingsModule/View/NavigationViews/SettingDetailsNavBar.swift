//
//  SettingAppearanceNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

struct SettingDetailsNavBar: View {
    
    private let title: String
    private var onDismiss: () -> Void
    
    init(title: String, onDismiss: @escaping () -> Void) {
        self.title = title
        self.onDismiss = onDismiss
    }
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                Color.BackColors.backDefault
                    .shadow(color: Color.ShadowColors.shadowDefault, radius: 15, x: 0, y: 5)
                
                content
                    .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    private var content: some View {
        HStack(spacing: 8) {
            backButton
            titleLabel
        }
    }
    
    private var backButton: some View {
        Button {
            onDismiss()
        } label: {
            Image.NavigationBar.back
                .resizable()
                .frame(width: 20, height: 20)
        }
        .padding(.leading)
    }
    
    private var titleLabel: some View {
        Text(title)
            .font(.system(size: 20, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SettingDetailsNavBar(title: "Task Creation Page") {}
}
