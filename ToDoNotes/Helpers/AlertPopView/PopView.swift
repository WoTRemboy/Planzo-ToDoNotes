//
//  PopView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/4/25.
//

import SwiftUI

// MARK: - Configuration Struct

/// Configuration for PopView appearance.
struct Config {
    /// Background color overlay behind the pop view.
    var backgroundColor: Color = .black.opacity(0.3)
}

// MARK: - View Extension

extension View {
    /// Adds a custom pop-up full-screen view on top of the current view.
    /// - Parameters:
    ///   - config: The configuration settings for the background overlay.
    ///   - isPresented: A binding to control the visibility of the pop view.
    ///   - onDismiss: Closure called when the pop view is dismissed.
    ///   - content: The content to display inside the pop view.
    /// - Returns: A view that presents a customizable pop-up overlay.
    @ViewBuilder
    internal func popView<Content: View>(
        config: Config = .init(),
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> (),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .modifier(
                PopViewHelper(
                    viewContent: content,
                    isPresented: isPresented,
                    config: config,
                    onDismiss: onDismiss))
    }
}

// MARK: - PopView Helper Modifier

/// A view modifier that handles presenting and animating a pop-up view over the current screen.
fileprivate struct PopViewHelper<ViewContent: View>: ViewModifier {
    
    // MARK: - Properties

    /// The content to be displayed inside the pop-up.
    @ViewBuilder var viewContent: ViewContent
    /// Binding to control the presentation state of the pop view.
    @Binding var isPresented: Bool
    /// Pop-up configuration parameters.
    var config: Config
    /// Closure to execute when the pop-up is dismissed.
    var onDismiss: () -> ()

    /// Internal state to control whether full screen cover is active.
    @State private var presentFullScreenCover: Bool = false
    /// Internal state to control animation of the pop-up appearance.
    @State private var animateView: Bool = false

    // MARK: - Body

    /// The main body of the modifier, presenting the pop-up overlay.
    /// - Parameter content: The underlying content view.
    /// - Returns: A view with a pop-up overlay when triggered.
    func body(content: Content) -> some View {
        let screenHeight = screenSize.height
        let animateView = animateView

        content
            .fullScreenCover(
                isPresented: $presentFullScreenCover,
                onDismiss: onDismiss) {
                    ZStack {
                        // Background dimmed layer, tap to dismiss
                        Rectangle()
                            .fill(config.backgroundColor)
                            .ignoresSafeArea()
                            .opacity(animateView ? 1 : 0)
                            .onTapGesture {
                                // Dismisses pop view when background is tapped
                                isPresented = false
                            }

                        // Main pop-up content with vertical animation
                        viewContent
                            .visualEffect({ content, proxy in
                                content
                                    .offset(y: offset(
                                        proxy,
                                        screenHeight: screenHeight,
                                        animateView: animateView))
                            })
                            .presentationBackground(.clear)
                            .task {
                                // Animates the view in when it appears
                                guard !animateView else { return }
                                withAnimation(.snappy(duration: 0.3)) {
                                    self.animateView = true
                                }
                            }
                            .ignoresSafeArea(.container, edges: .all)
                    }
                }
            .onChange(of: isPresented) { _, newValue in
                // Responds to changes in isPresented binding
                if newValue {
                    // Shows the pop view
                    toggleView(true)
                } else {
                    // Hides the pop view with animation and delay
                    Task {
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                            self.animateView = false
                        }
                        try? await Task.sleep(for: .seconds(0.35))
                        toggleView(false)
                    }
                }
            }
    }

    // MARK: - Private Helpers

    /// Calculates vertical offset for animating the pop view based on its visibility.
    /// - Parameters:
    ///   - proxy: GeometryProxy for measuring view size.
    ///   - screenHeight: Height of the screen.
    ///   - animateView: Whether animation is active.
    /// - Returns: Y offset for the pop view.
    nonisolated private func offset(_ proxy: GeometryProxy, screenHeight: CGFloat, animateView: Bool) -> CGFloat {
        let viewHeight = proxy.size.height
        // When not animating, moves the pop view off screen; else, show at center
        return animateView ? 0 : (screenHeight + viewHeight) / 2
    }

    /// Toggles the state of full screen presentation instantly without animation.
    /// - Parameter status: New presentation state.
    private func toggleView(_ status: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            presentFullScreenCover = status
        }
    }

    /// Retrieves the screen size of the main window.
    private var screenSize: CGSize {
        if let screenSize = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return screenSize
        }
        return .zero
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
