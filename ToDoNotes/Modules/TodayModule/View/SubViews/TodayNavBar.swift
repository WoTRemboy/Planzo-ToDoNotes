//
//  TodayNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

/// A custom navigation bar for the Today screen.
/// Displays the current date, weekday, search, and importance toggle actions.
struct TodayNavBar: View {
    
    // MARK: - Properties
    
    /// View model for controlling search and importance states.
    @EnvironmentObject private var viewModel: TodayViewModel
    @Namespace private var glassNamespace
    private let searchMorphID = "TodayNavBarSearchMorph"
    
    /// A string representing today's date.
    private let date: String
    /// A string representing the day of the week.
    private let day: String
    
    // MARK: - Initialization
    
    /// Initializes a new TodayNavBar with the given date and day.
    /// - Parameters:
    ///   - date: The formatted current date string.
    ///   - day: The current weekday string.
    init(date: String, day: String) {
        self.date = date
        self.day = day
    }
    
    // MARK: - Body
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                // Background color with shadow
                if #available(iOS 26.0, *) {} else {
                    background
                }
                
                VStack(spacing: 0) {
                    if viewModel.showingSearchBar {
                        searchBar
                            .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        navContent
                            .transition(.blurReplace)
                    }
                }
                .padding(.top, topInset + (viewModel.showingSearchBar ? 5 : 9.5))
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    // MARK: - Subviews
    
    /// Background of the navigation bar with shadow.
    @ViewBuilder
    private var background: some View {
        if #available(iOS 26.0, *) {} else {
            Color.SupportColors.supportNavBar
                .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
        }
    }
    
    /// Main navigation content with title and action buttons.
    private var navContent: some View {
        HStack {
            titleLabel
            actionButtons
        }
    }
    
    /// Displays the formatted date and weekday.
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
    
    /// Search bar displayed when toggled.
    private var searchBar: some View {
        SearchBar(text: $viewModel.searchText) {
            viewModel.toggleShowingSearchBar()
        }
    }
    
    // MARK: - Action Buttons
    
    /// Displays action buttons for search and important toggle.
    private var actionButtons: some View {
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 6) {
                    HStack(spacing: 6) {
                        glassActionButton(content: searchButtonContent,
                                          action: searchAction)
                        glassActionButton(content: importantButtonContent,
                                          action: importantAction)
                    }
                }
            } else {
                HStack(spacing: 20) {
                    searchButton
                    importantButton
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var searchButtonContent: some View {
        if #available(iOS 26.0, *) {
            Image.NavigationBar.search
                .resizable()
                .frame(width: 26, height: 26)
                .matchedGeometryEffect(id: searchMorphID, in: glassNamespace)
        } else {
            Image.NavigationBar.search
                .resizable()
                .frame(width: 26, height: 26)
        }
    }

    private var importantButtonContent: some View {
        (viewModel.importance
         ? Image.NavigationBar.MainTodayPages.importantDeselect
         : Image.NavigationBar.MainTodayPages.importantSelect)
        .resizable()
        .frame(width: 26, height: 26)
        .shadow(color: Color.ShadowColors.navBar,
                radius: viewModel.importance ? 5 : 0)
    }

    private func searchAction() {
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.toggleShowingSearchBar()
        }
    }

    private func importantAction() {
        viewModel.toggleImportance()
    }

    /// Button to toggle the search bar.
    private var searchButton: some View {
        Button {
            searchAction()
        } label: {
            searchButtonContent
        }
    }
    
    /// Button to toggle the importance filter.
    private var importantButton: some View {
        Button {
            importantAction()
        } label: {
            importantButtonContent
        }
    }

    @available(iOS 26.0, *)
    @ViewBuilder
    private func glassActionButton<Content: View>(content: Content, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            content
                .padding(8)
        }
        .glassEffect(.regular.interactive())
        .glassEffectUnion(id: "TodayNavBarActions", namespace: glassNamespace)
    }
}

// MARK: - Preview

#Preview {
    TodayNavBar(date: "18 January", day: "Sun")
        .environmentObject(TodayViewModel())
}
