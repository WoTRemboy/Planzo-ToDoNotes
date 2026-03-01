//
//  SubscriptionNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import SwiftUI

struct SubscriptionNavBar: View {
    
    // MARK: - Properties
    
    /// Provides access to the environment's dismiss action for navigating back.
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthNetworkService
    @EnvironmentObject private var viewModel: SubscriptionViewModel
    @Namespace private var glassNamespace
    
    /// The title text to display in the navigation bar.
    private let title: String
    /// A Boolean flag indicating whether a back button should be displayed.
    private let showBackButton: Bool
    
    // MARK: - Initializer
    /// Initializes a new `CustomNavBar`.
    /// - Parameters:
    ///   - title: The title text displayed in the navigation bar.
    ///   - showBackButton: A flag to determine whether to show a back button. Default is `false`.
    init(title: String, showBackButton: Bool = false) {
        self.title = title
        self.showBackButton = showBackButton
    }
    
    // MARK: - Body
    
    /// The content and layout of the navigation bar view.
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                if #available(iOS 26.0, *) {} else {
                    Color.SupportColors.supportNavBar
                        .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
                }
                
                content
                    .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    // MARK: - Subviews
    
    /// Builds the main content view of the navigation bar, containing the back button (if shown) and title label.
    private var content: some View {
        HStack(spacing: 0) {
            if showBackButton {
                backButton
            }
            titleLabel
            Spacer()
            
            if authService.isAuthorized {
                restoreButton
            }
        }
        .animation(.easeInOut(duration: 0.2), value: authService.isAuthorized)
    }
    
    /// A button that dismisses the current view when tapped. Shown only if `showBackButton` is `true`.
    private var backButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 6) {
                    HStack(spacing: 6) {
                        glassActionButton(content: backButtonContent) {
                            dismiss()
                        }
                    }
                }
            } else {
                Button {
                    dismiss()
                } label: {
                    backButtonContent
                }
            }
        }
        .padding(.leading, 16)
    }
    
    /// A text label displaying the navigation bar's title.
    private var titleLabel: some View {
        Text(title)
            .font(.system(size: 20, weight: .medium))
            .frame(alignment: .leading)
            .padding(.leading, showBackButton ? 8 : 16)
    }
    
    private var backButtonContent: some View {
        Image.NavigationBar.hide
            .resizable()
            .frame(width: 24, height: 24)
    }

    private var restoreButtonContent: some View {
        Text(Texts.Subscription.Page.restore)
            .foregroundStyle(Color.LabelColors.labelPrimary)
    }

    private func restorePurchases() {
        viewModel.restorePurchases { success in
            if success {
                authService.loadPersistedProfile()
            }
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
        .glassEffectUnion(id: "SubscriptionNavBarActions", namespace: glassNamespace)
    }

    private var restoreButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 6) {
                    HStack(spacing: 6) {
                        glassActionButton(content: restoreButtonContent,
                                          action: restorePurchases)
                    }
                }
            } else {
                Button {
                    restorePurchases()
                } label: {
                    restoreButtonContent
                }
            }
        }
        .transition(.blurReplace)
        .frame(alignment: .trailing)
        .padding(.trailing, 16)
    }
}

// MARK: - Preview

#Preview {
    SubscriptionNavBar(title: "Pro Plan", showBackButton: true)
        .environmentObject(AuthNetworkService())
        .environmentObject(SubscriptionViewModel())
}
