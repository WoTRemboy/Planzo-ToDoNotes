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
        onTap: @escaping () -> (),
        onDismiss: @escaping () -> (),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .modifier(
                PopViewHelper(
                    viewContent: content,
                    isPresented: isPresented,
                    config: config,
                    onTap: onTap,
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
    var onTap: () -> ()
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
                                onTap()
                            }

                        if animateView {
                            viewContent
                                .transition(.blurReplace.combined(with: .push(from: .bottom)))
                                .contentShape(Rectangle())
                                .ignoresSafeArea(.container, edges: .all)
                        }
                    }
                    .presentationBackground(.clear)
                    .onAppear {
                        guard !animateView else { return }

                        Task { @MainActor in
                            await Task.yield()
                            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                                animateView = true
                            }
                        }
                    }
                }
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    showOverlay()
                } else {
                    hideOverlay()
                }
            }
    }

    // MARK: - Private Helpers

    private func showOverlay() {
        guard !presentFullScreenCover else { return }

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            presentFullScreenCover = true
            animateView = false
        }
    }

    private func hideOverlay() {
        Task { @MainActor in
            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                animateView = false
            }

            try? await Task.sleep(for: .seconds(0.35))

            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                presentFullScreenCover = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AuthNetworkService())
        .environmentObject(PasscodeManager())
}
