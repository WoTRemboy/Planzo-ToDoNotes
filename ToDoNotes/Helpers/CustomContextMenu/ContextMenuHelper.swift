//
//  ContextMenuHelper.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/20/25.
//

import SwiftUI

/// A generic SwiftUI helper for integrating UIKit context menus with customizable content, preview, and actions.
struct ContextMenuHelper<Content: View, Preview: View>: UIViewRepresentable {
    
    // MARK: - Properties
    
    /// The main SwiftUI content view.
    private var content: Content
    /// The SwiftUI view shown as a preview in the context menu.
    private var preview: Preview
    /// The menu provider for actions available in the context menu.
    private var actionsProvider: () -> UIMenu
    /// A closure triggered when the context menu interaction ends.
    private var onEnd: () -> ()
    
    // MARK: - Initialization
    
    /// Initializes a new ContextMenuHelper.
    /// - Parameters:
    ///   - content: The SwiftUI view that should support the context menu.
    ///   - preview: The SwiftUI view that will be used as a preview in the context menu.
    ///   - actionsProvider: A closure that provides the actions menu on demand.
    ///   - onEnd: A closure to execute when the context menu interaction finishes.
    init(content: Content, preview: Preview, actionsProvider: @escaping () -> UIMenu, onEnd: @escaping () -> Void) {
        self.content = content
        self.preview = preview
        self.actionsProvider = actionsProvider
        self.onEnd = onEnd
    }
    
    // MARK: - UIViewRepresentable
    
    /// Creates the coordinator object to act as the delegate.
    internal func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    /// Creates the UIView that hosts the SwiftUI content and adds the context menu interaction.
    internal func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        context.coordinator.hostingController = UIHostingController(rootView: content)
        guard let hostView = context.coordinator.hostingController?.view else { return view }
        
        view.addSubview(hostView)
        hostView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostView.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)
        return view
    }
    
    /// Updates the UIView with the current SwiftUI content.
    internal func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.hostingController?.rootView = content
        context.coordinator.parent = self
    }
    
    // MARK: - Coordinator
    
    /// A coordinator that acts as the delegate for `UIContextMenuInteraction`.
    final class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        
        var parent: ContextMenuHelper
        var hostingController: UIHostingController<Content>?
        
        /// Initializes a new Coordinator with its parent.
        /// - Parameter parent: The `ContextMenuHelper` instance that owns this coordinator.
        init(parent: ContextMenuHelper) {
            self.parent = parent
        }
        
        /// Provides the configuration for displaying the context menu.
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            
            return UIContextMenuConfiguration(identifier: nil) {
                let hostingController = UIHostingController(rootView: self.parent.preview)
                hostingController.preferredContentSize = CGSize(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height / 2
                )
                return hostingController
            } actionProvider: { _ in
                self.parent.actionsProvider()
            }
        }
        
        /// Called when the user commits the context menu preview.
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
//            animator.addCompletion {
//                self.parent.onEnd()
//            }
        }
    }
}
