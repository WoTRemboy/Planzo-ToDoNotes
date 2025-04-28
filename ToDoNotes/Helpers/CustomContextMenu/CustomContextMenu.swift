//
//  CustomContextMenu.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/20/25.
//

import SwiftUI

/// A customizable context menu view that shows a preview and actions on long-press.
struct CustomContextMenu<Content: View, Preview: View>: View {
    
    // MARK: - Properties
    
    /// The main content view that the context menu is attached to.
    private var content: Content
    /// The preview view shown when the context menu is activated.
    private var preview: Preview
    /// The menu containing actions available in the context menu.
    private var menu: UIMenu
    /// The closure called when the context menu interaction ends.
    private var onEnd: () -> ()
    
    // MARK: - Initializer
    
    /// Initializes a new `CustomContextMenu`.
    /// - Parameters:
    ///   - content: A closure returning the main content view.
    ///   - preview: A closure returning the preview view shown on long-press.
    ///   - actions: A closure returning a `UIMenu` defining the context actions.
    ///   - onEnd: A closure executed when the context menu interaction ends.
    init(@ViewBuilder content: @escaping () -> Content,
         @ViewBuilder preview: @escaping () -> Preview,
         actions: @escaping () -> UIMenu,
         onEnd: @escaping () -> ()
    ) {
        self.content = content()
        self.preview = preview()
        self.menu = actions()
        self.onEnd = onEnd
    }
    
    // MARK: - Body
    
    /// The content and behavior of the context menu.
    internal var body: some View {
        ZStack {
            content
                .hidden() // Hides the original content visually but keeps its space.
                .overlay {
                    ContextMenuHelper(content: content,
                                      preview: preview,
                                      actions: menu,
                                      onEnd: onEnd)
                }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
