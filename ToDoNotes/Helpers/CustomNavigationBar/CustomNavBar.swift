//
//  CustomNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

struct CustomNavBar: View {
    @Environment(\.dismiss) private var dismiss
    
    private let title: String
    private let showBackButton: Bool
    
    init(title: String, showBackButton: Bool = false) {
        self.title = title
        self.showBackButton = showBackButton
    }
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                Color.SupportColors.supportNavBar
                    .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
                
                content
                    .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    private var content: some View {
        HStack(spacing: 0) {
            if showBackButton {
                backButton
            }
            titleLabel
        }
    }
    
    private var backButton: some View {
        Button {
            dismiss()
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
            .padding(.leading, showBackButton ? 8 : 16)
    }
}

#Preview {
    CustomNavBar(title: "Task Creation Page", showBackButton: true)
}
