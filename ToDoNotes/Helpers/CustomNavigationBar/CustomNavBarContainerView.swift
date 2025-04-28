//
//  CustomNavBarContainerView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/1/25.
//

import SwiftUI

/// A container view that provides a customizable navigation bar at the top,
/// and displays a content view underneath.
struct CustomNavBarContainerView<Content: View>: View {
    
    // MARK: - Properties
    
    /// The title to display in the custom navigation bar.
    @State private var title: String = String()
    /// A flag that indicates whether the back button should be shown in the custom navigation bar.
    @State private var showBackButton: Bool = false
    /// The content view displayed below the navigation bar.
    private let content: Content
    
    // MARK: - Initializer
    
    /// Initializes the container view with the given content.
    /// - Parameter content: A closure returning the `Content` view to be embedded.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    // MARK: - Body
    
    internal var body: some View {
        VStack(spacing: 0) {
            // Top navigation bar with dynamic title and back button
            CustomNavBar(
                title: title,
                showBackButton: showBackButton)
            
            content
        }
        .onPreferenceChange(CustomNavBarTitlePreferenceKey.self, perform: { value in
            // Updates the navigation bar title when preference changes
            self.title = value
        })
        .onPreferenceChange(CustomNavBarBackButtonPreferenceKey.self, perform: { value in
            // Updates the back button visibility when preference changes
            self.showBackButton = value
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Preview

#Preview {
    CustomNavBarContainerView {
        Text("Content")
            .customNavBarItems(title: "Title", showBackButton: true)
    }
}
