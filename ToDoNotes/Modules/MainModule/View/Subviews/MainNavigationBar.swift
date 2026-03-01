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
    @ObservedObject private var syncService = FullSyncNetworkService.shared
    @Namespace private var glassNamespace
    
    @State private var isRotating = false
    
    /// The title displayed in the navigation bar.
    private let title: String
    private let namespace: Namespace.ID
    
    init(title: String, namespace: Namespace.ID) {
        self.title = title
        self.namespace = namespace
    }
    
    // MARK: - Body
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                // Background with shadow
                background
                
                VStack(spacing: 0) {
                    if viewModel.showingSearchBar {
                        // If search is active, shows search bar
                        SearchBar(text: $viewModel.searchText) {
                            viewModel.toggleShowingSearchBar()
                        }
                        .padding(.bottom, searchBarPadding)
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
                        .padding(.top, foldersTopPadding)
                }
                .padding(.top, topInset + 8)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: navBarHeight)
    }

    private var navBarHeight: CGFloat {
        if #available(iOS 26.0, *) {
            return 190
        }
        return 140
    }

    private var foldersTopPadding: CGFloat {
        if #available(iOS 26.0, *) {
            return 0
        }
        return 10
    }

    @ViewBuilder
    private var background: some View {
        if #available(iOS 26.0, *) {} else {
            Color.SupportColors.supportNavBar
                .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
        }
    }
    
    // MARK: - Title Label
    
    /// Displays the main title on the navigation bar.
    private var titleLabel: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 25, weight: .bold))
                .frame(alignment: .leading)
                .padding(.leading, 16)
            
            if authService.currentUser?.isPremium == true {
                Text(Texts.Subscription.SubType.pro)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(Color.LabelColors.labelSubscription)
            }
            
            if syncService.lastSyncStatus == .failed {
                Image.Settings.syncError
                    .resizable()
                    .frame(width: 22, height: 22)
                    .onTapGesture {
                        viewModel.toggleShowingSyncErrorAlert()
                    }
            } else if syncService.lastSyncStatus == .updating {
                updatingIcon
            }
        }
        .transition(.blurReplace)
        .animation(.easeInOut(duration: 0.2), value: syncService.lastSyncStatus)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var updatingIcon: some View {
        Image.Settings.syncUpdating
            .resizable()
            .frame(width: 22, height: 22)
            .rotationEffect(Angle.degrees(isRotating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isRotating)
            .onAppear {
                isRotating = true
            }
            .onDisappear {
                isRotating = false
            }
            .transition(.scale)
    }
    
    // MARK: - Action Buttons
    
    /// Action buttons for search and importance toggle.
    private var buttons: some View {
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 6) {
                    HStack(spacing: 6) {
                        if shouldShowSubscription {
                            glassTintActionButton(content: subscriptionButtonContent,
                                                  tint: Color.LabelColors.labelPrimary,
                                                  action: subscriptionButtonAction)
                            .padding(.trailing, 8)
                        }
                        glassActionButton(content: searchButtonContent,
                                          action: searchButtonAction)
                        glassActionButton(content: importanceButtonContent,
                                          action: importanceButtonAction)
                    }
                }
            } else {
                HStack(spacing: 20) {
                    if shouldShowSubscription {
                        subscriptionButton
                    }
                    Button {
                        searchButtonAction()
                    } label: {
                        searchButtonContent
                    }
                    Button {
                        importanceButtonAction()
                    } label: {
                        importanceButtonContent
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var shouldShowSubscription: Bool {
        authService.currentUser?.isPremium == false || authService.currentUser == nil
    }

    private var searchButtonContent: some View {
        Image.NavigationBar.search
            .resizable()
            .frame(width: 26, height: 26)
    }

    private var importanceButtonContent: some View {
        (viewModel.importance ?
        Image.NavigationBar.MainTodayPages.importantDeselect :
        Image.NavigationBar.MainTodayPages.importantSelect)
            .resizable()
            .frame(width: 26, height: 26)
            .shadow(color: Color.ShadowColors.navBar,
                    radius: viewModel.importance ? 5 : 0)
    }

    private var subscriptionButtonContent: some View {
        Text(Texts.Subscription.SubType.pro)
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(Color.LabelColors.labelSubscriptionAd)
            .padding(.horizontal)
    }

    private func searchButtonAction() {
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.toggleShowingSearchBar()
        }
    }

    private func importanceButtonAction() {
        viewModel.toggleImportance()
    }

    private func subscriptionButtonAction() {
        viewModel.toggleShowingSubscriptionPage()
    }

    private var subscriptionButton: some View {
        Button {
            subscriptionButtonAction()
        } label: {
            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .frame(width: 48, height: 26)
                .overlay {
                    Text(Texts.Subscription.SubType.pro)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(Color.LabelColors.labelSubscriptionAd)
                }
        }
        .interactiveGlassIfAvailable()
        .navigationTransitionSource(
            id: Texts.NamespaceID.subscriptionButton,
            namespace: namespace)
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
        .glassEffectUnion(id: "MainNavBarActions", namespace: glassNamespace)
    }

    @available(iOS 26.0, *)
    @ViewBuilder
    private func glassTintActionButton<Content: View>(content: Content, tint: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            content
                .padding(.vertical, 8)
        }
        .frame(width: 70)
        .glassEffect(.regular.tint(tint).interactive())
    }
    
    private var searchBarPadding: CGFloat {
        if #available(iOS 26.0, *) {
            return 6
        }
        return 0
    }
    
}

// MARK: - Preview

#Preview {
    MainCustomNavBar(title: Texts.MainPage.title, namespace: Namespace().wrappedValue)
        .environmentObject(MainViewModel())
        .environmentObject(AuthNetworkService())
}
