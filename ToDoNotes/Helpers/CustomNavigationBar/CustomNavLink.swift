//
//  CustomNavLink.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/1/25.
//

import SwiftUI

/// A customizable navigation link component that wraps a destination view inside a custom navigation bar container.
struct CustomNavLink<Label: View, Destination: View>: View {
    
    // MARK: - Properties
    
    /// The destination view to navigate to when the link is activated.
    private let destination: Destination
    /// The label view that represents the navigation link.
    private let label: Label
    
    // MARK: - Initialization
    
    /// Initializes a new `CustomNavLink` with a destination view and a label view builder.
    /// - Parameters:
    ///   - destination: The destination view to navigate to.
    ///   - label: A view builder that creates the label for the navigation link.
    init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }
    
    // MARK: - Body
    
    /// The view's content and behavior.
    var body: some View {
        NavigationLink {
            // Wrap destination in a custom navigation bar container view.
            CustomNavBarContainerView() {
                destination
            }
            .navigationBarHidden(true)
            // Enable full swipe gesture to pop the navigation stack.
            .enableFullSwipePop(true)
        } label: {
            label
        }

    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CustomNavLink(
            destination: Text("Destination")) {
                Text("Navigate")
            }
    }
}
