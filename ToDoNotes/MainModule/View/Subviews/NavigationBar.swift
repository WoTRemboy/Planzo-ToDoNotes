//
//  NavigationBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct CustomNavBar: View {
    private let title: String
    
    init(title: String) {
        self.title = title
    }
    
    internal var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .background(.ultraThinMaterial)
                .blur(radius: 10)
            
            HStack {
                titleLabel
                buttons
            }
            .padding(.bottom)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var titleLabel: some View {
        Text(title)
            .font(.system(size: 20, weight: .regular))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
    }
    
    private var buttons: some View {
        HStack(spacing: 20) {
            // Search Button
            Button {
                
            } label: {
                Image.NavigationBar.search
            }
            
            // Favorites Button
            Button {
                
            } label: {
                Image.NavigationBar.favorites
            }
        }
        .padding(.horizontal, 16)
    }
    
}

#Preview {
    CustomNavBar(title: Texts.MainPage.title)
}
