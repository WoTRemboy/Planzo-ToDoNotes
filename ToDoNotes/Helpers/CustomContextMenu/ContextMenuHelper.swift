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
    
    init(content: Content, preview: Preview, actions: UIMenu, onEnd: @escaping () -> ()) {
        self.content = content
        self.preview = preview
        self.actions = actions
        self.onEnd = onEnd
    }
    
    internal func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    internal func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let hostView = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            hostView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostView.view.heightAnchor.constraint(equalTo: view.heightAnchor)
        ]
        view.addSubview(hostView.view)
        view.addConstraints(constraints)
        
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)
        return view
    }
    
    internal func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    final class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        
        var parent: ContextMenuHelper
        
        init(parent: ContextMenuHelper) {
            self.parent = parent
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            
            return UIContextMenuConfiguration(identifier: nil) {
                let previewController = UIHostingController(rootView: self.parent.preview)
                return previewController
            } actionProvider: { items in
                return self.parent.actions
            }
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
            
//            animator.addCompletion {
//                self.parent.onEnd()
//            }
        }
    }
    
}
