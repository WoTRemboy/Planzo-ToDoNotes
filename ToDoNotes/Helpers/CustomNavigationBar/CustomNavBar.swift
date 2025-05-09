//
//  CustomNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

/// A customizable navigation bar with optional back button support.
struct CustomNavBar: View {

    // MARK: - Properties
    
    /// Provides access to the environment's dismiss action for navigating back.
    @Environment(\.dismiss) private var dismiss

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
                Color.SupportColors.supportNavBar
                    .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)

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
        }
    }

    /// A button that dismisses the current view when tapped. Shown only if `showBackButton` is `true`.
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

    /// A text label displaying the navigation bar's title.
    private var titleLabel: some View {
        Text(title)
            .font(.system(size: 20, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, showBackButton ? 8 : 16)
    }
}

// MARK: - Preview

#Preview {
    CustomNavBar(title: "Task Creation Page", showBackButton: true)
}
