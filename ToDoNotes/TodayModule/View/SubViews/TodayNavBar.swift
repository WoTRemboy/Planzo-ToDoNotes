//
//  TodayNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct TodayNavBar: View {
    @EnvironmentObject private var viewModel: TodayViewModel
    
    private let date: String
    private let day: String
    
    init(date: String, day: String) {
        self.date = date
        self.day = day
    }
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                Color.SupportColors.supportNavBar
                    .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
                
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
                }
                .padding(.top, topInset + (viewModel.showingSearchBar ? 5 : 9.5))
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    private var titleLabel: some View {
        HStack(spacing: 8) {
            Text(date)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelPrimary)
            
            Text(day)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelSecondary)
        }
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
                    .shadow(color: Color.ShadowColors.navBar,
                            radius: viewModel.importance ? 5 : 0)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    TodayNavBar(date: "18 January", day: "Sun")
        .environmentObject(TodayViewModel())
}
