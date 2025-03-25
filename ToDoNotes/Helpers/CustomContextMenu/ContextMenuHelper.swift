//
//  ContextMenuHelper.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/20/25.
//

import SwiftUI

struct ContextMenuHelper<Content: View, Preview: View>: UIViewRepresentable {
    private var content: Content
    private var preview: Preview
    private var actions: UIMenu
    private var onEnd: () -> ()
    
    init(content: Content, preview: Preview, actions: UIMenu, onEnd: @escaping () -> Void) {
        self.content = content
        self.preview = preview
        self.actions = actions
        self.onEnd = onEnd
    }
    
    internal func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
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
    
    internal func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.hostingController?.rootView = content
    }
    
    final class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        
        var parent: ContextMenuHelper
        var hostingController: UIHostingController<Content>?
        
        init(parent: ContextMenuHelper) {
            self.parent = parent
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            
            return UIContextMenuConfiguration(identifier: nil) {
                UIHostingController(rootView: self.parent.preview)
            } actionProvider: { _ in
                self.parent.actions
            }
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
//            animator.addCompletion {
//                self.parent.onEnd()
//            }
        }
    }
}
