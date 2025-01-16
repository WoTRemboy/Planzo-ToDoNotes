//
//  NavigationBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct MainCustomNavBar: View {
    private let title: String
    
    init(title: String) {
        self.title = title
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack {
                titleLabel
                buttons
            }
            FilterScrollView()
                .padding(.top, 16)
            FoldersScrollView()
                .padding(.top, 12)
        }
        .frame(height: 140)
    }
    
    private var titleLabel: some View {
        Text(title)
            .font(.system(size: 20, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
    }
    
    private var buttons: some View {
        HStack(spacing: 20) {
            // Search Button
            Button {
                // Action for search button
            } label: {
                Image.NavigationBar.search
            }
            
            // Favorites Button
            Button {
                // Action for favorites button
            } label: {
                Image.NavigationBar.favorites
            }
        }
        .padding(.horizontal, 16)
    }
    
}

#Preview {
    MainCustomNavBar(title: Texts.MainPage.title)
        .environmentObject(MainViewModel())
}
