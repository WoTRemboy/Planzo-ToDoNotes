//
//  CustomContextMenu.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/20/25.
//

import SwiftUI

struct CustomContextMenu<Content: View, Preview: View>: View {
    
    private var content: Content
    private var preview: Preview
    private var menu: UIMenu
    private var onEnd: () -> ()
    
    init(@ViewBuilder content: @escaping () -> Content,
         @ViewBuilder preview: @escaping () -> Preview,
         actions: @escaping () -> UIMenu,
         onEnd: @escaping () -> ()) {
        self.content = content()
        self.preview = preview()
        self.menu = actions()
        self.onEnd = onEnd
    }
    
    internal var body: some View {
        ZStack {
            content
                .hidden()
                .overlay {
                    ContextMenuHelper(content: content,
                                      preview: preview,
                                      actions: menu,
                                      onEnd: onEnd)
                }
        }
    }
}

#Preview {
    ContentView()
}
