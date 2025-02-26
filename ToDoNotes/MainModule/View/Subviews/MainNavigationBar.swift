//
//  NavigationBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct MainCustomNavBar: View {
    @State private var safeAreaTop: CGFloat = 0
    
    private let title: String
    
    init(title: String) {
        self.title = title
    }
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                Color.BackColors.backDefault
                    .shadow(color: Color.ShadowColors.shadowDefault, radius: 15, x: 0, y: 5)
                
                VStack(spacing: 0) {
                    HStack {
                        titleLabel
                        buttons
                    }
                    FilterScrollView()
                        .padding(.top, 10)
                    FoldersScrollView()
                        .padding(.top, 10)
                }
                .padding(.top, topInset + 8)
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                safeAreaTop = topInset
            }
            
        }
        .frame(height: 140)
    }
    
    private var titleLabel: some View {
        Text(title)
            .font(.system(size: 25, weight: .bold))
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
                    .resizable()
                    .frame(width: 26, height: 26)
            }
            
            // Favorites Button
            Button {
                // Action for favorites button
            } label: {
                Image.NavigationBar.favorites
                    .resizable()
                    .frame(width: 26, height: 26)
            }
        }
        .padding(.horizontal, 16)
    }
    
}

#Preview {
    MainCustomNavBar(title: Texts.MainPage.title)
        .environmentObject(MainViewModel())
}
