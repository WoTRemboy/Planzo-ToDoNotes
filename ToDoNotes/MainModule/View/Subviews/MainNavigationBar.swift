//
//  NavigationBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct MainCustomNavBar: View {
    
    @EnvironmentObject private var viewModel: MainViewModel
    
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
                    if viewModel.showingSearchBar {
                        SearchBar(text: $viewModel.searchText) {
                            viewModel.toggleShowingSearchBar()
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        HStack {
                            titleLabel
                            buttons
                        }
                        .transition(.blurReplace)
                    }
                    FilterScrollView()
                        .padding(.top, viewModel.showingSearchBar ? 2 : 10)
                    FoldersScrollView()
                        .padding(.top, 10)
                }
                .padding(.top, topInset + 8)
            }
            .ignoresSafeArea(edges: .top)
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
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleShowingSearchBar()
                }
            } label: {
                Image.NavigationBar.search
                    .resizable()
                    .frame(width: 26, height: 26)
            }
            
            // Favorites Button
            Button {
                viewModel.toggleImportance()
            } label: {
                (viewModel.importance ?
                Image.NavigationBar.MainTodayPages.importantDeselect :
                Image.NavigationBar.MainTodayPages.importantSelect)
                    .resizable()
                    .frame(width: 26, height: 26)
                    .shadow(color: Color.ShadowColors.shadowDefault,
                            radius: viewModel.importance ? 5 : 0)
            }
        }
        .padding(.horizontal, 16)
    }
    
}

#Preview {
    MainCustomNavBar(title: Texts.MainPage.title)
        .environmentObject(MainViewModel())
}
