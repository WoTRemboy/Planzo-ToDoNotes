//
//  NavigationBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

/// Custom navigation bar for the main page.
/// Displays either a title with action buttons or a search bar, depending on the search state.
struct MainCustomNavBar: View {
    
    @EnvironmentObject private var authService: AuthNetworkService
    @EnvironmentObject private var viewModel: MainViewModel
    
    /// The title displayed in the navigation bar.
    private let title: String
    
    init(title: String) {
        self.title = title
    }
    
    // MARK: - Body
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                // Background with shadow
                Color.SupportColors.supportNavBar
                    .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
                
                VStack(spacing: 0) {
                    if viewModel.showingSearchBar {
                        // If search is active, shows search bar
                        SearchBar(text: $viewModel.searchText) {
                            viewModel.toggleShowingSearchBar()
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        // Otherwise, shows title and action buttons
                        HStack {
                            titleLabel
                            buttons
                        }
                        .transition(.blurReplace)
                    }
                    // Filter section
                    FilterScrollView()
                        .padding(.top, viewModel.showingSearchBar ? 2 : 10)
                    // Folder section
                    FoldersScrollView()
                        .padding(.top, 10)
                }
                .padding(.top, topInset + 8)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 140)
    }
    
    // MARK: - Title Label
    
    /// Displays the main title on the navigation bar.
    private var titleLabel: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 25, weight: .bold))
                .frame(alignment: .leading)
                .padding(.leading, 16)
            
            if authService.currentUser?.isPro == true {
                Text(Texts.Subscription.SubType.pro)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(Color.LabelColors.labelSubscription)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Action Buttons
    
    /// Action buttons for search and importance toggle.
    private var buttons: some View {
        HStack(spacing: 20) {
            if authService.currentUser?.isFree == true || authService.currentUser == nil {
                subscriptionButton
            }
            
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
            
            // Favorites Button (importance toggle)
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
    
    private var subscriptionButton: some View {
        Button {
            viewModel.toggleShowingSubscriptionPage()
        } label: {
            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(Color.LabelColors.labelSubscription)
                .frame(width: 48, height: 26)
                .overlay {
                    Text(Texts.Subscription.SubType.pro)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(Color.LabelColors.labelBlack)
                }
        }
    }
    
}

// MARK: - Preview

#Preview {
    MainCustomNavBar(title: Texts.MainPage.title)
        .environmentObject(MainViewModel())
        .environmentObject(AuthNetworkService())
}
