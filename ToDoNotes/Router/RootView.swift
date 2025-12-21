//
//  RootView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import SwiftUI

/// A root-level wrapper view that injects an overlay window for toast messages
/// and dynamically updates its appearance based on the selected app theme.
struct RootView<Content: View>: View {
    
    // MARK: - Properties
    
    /// Stores the user's selected theme from UserDefaults.
    @AppStorage(Texts.UserDefaults.theme)
    private var userTheme: Theme = .systemDefault
    
    /// The main content of the app, passed in by the parent.
    @ViewBuilder internal var content: Content
    /// A reference to the overlay window used to display toasts.
    @State private var overlayWindow: UIWindow?
    /// A reference to the hosting controller displaying the toast views.
    @State private var toastHostingController: UIHostingController<AnyView>? = nil

    /// A reference to the overlay window used to display loading overlays.
    @State private var loadingOverlayWindow: UIWindow?
    /// A reference to the hosting controller displaying the loading overlay views.
    @State private var loadingOverlayHostingController: UIHostingController<AnyView>? = nil
    
    // MARK: - Body
    
    /// The main body of the view.
    internal var body: some View {
        content
            .onAppear {
                // Initializes the overlay window for toast display if it doesn't exist
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   overlayWindow == nil {
                    
                    let window = PassthroughWindow(windowScene: windowScene)
                    window.backgroundColor = .clear
                    
                    let controller = UIHostingController(rootView: AnyView(
                        ToastGroup().preferredColorScheme(userTheme.colorScheme)
                    ))
                    controller.view.frame = windowScene.keyWindow?.frame ?? .zero
                    controller.view.backgroundColor = .clear
                    window.rootViewController = controller
                    
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    window.tag = 1009
                    
                    overlayWindow = window
                    toastHostingController = controller
                }
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   loadingOverlayWindow == nil {
                    
                    let window = UIWindow(windowScene: windowScene)
                    window.backgroundColor = .clear
                    window.windowLevel = .alert
                    
                    let controller = UIHostingController(rootView: AnyView(
                        LoadingOverlayGroup().preferredColorScheme(userTheme.colorScheme)
                    ))
                    controller.view.frame = windowScene.keyWindow?.frame ?? .zero
                    controller.view.backgroundColor = .clear
                    window.rootViewController = controller
                    
                    window.isHidden = false
                    window.isUserInteractionEnabled = false
                    window.tag = 1010
                    
                    loadingOverlayWindow = window
                    loadingOverlayHostingController = controller
                }
            }
            .onChange(of: userTheme) { _, newTheme in
                // Smoothly updates the toast appearance when theme changes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    toastHostingController?.rootView = AnyView(
                        ToastGroup().preferredColorScheme(newTheme.colorScheme)
                    )
                    
                    loadingOverlayHostingController?.rootView = AnyView(
                        LoadingOverlayGroup().preferredColorScheme(newTheme.colorScheme)
                    )
                }
            }
    }
}

// MARK: - PassthroughWindow

/// A custom window that allows touch events to pass through to views below it,
/// except for the actual content inside the toast container.
fileprivate class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        // Ignores touches that hit the root toast view (allow them to pass through)
        return rootViewController?.view == view ? nil : view
    }
}
