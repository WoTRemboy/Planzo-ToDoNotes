//
//  ImmediateKeyboardModifier.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/20/25.
//

import SwiftUI
import UIKit

struct ImmediateKeyboardModifier: ViewModifier {
    @State private var isFirstResponder: Bool = false
    
    internal func body(content: Content) -> some View {
        content
            .background(ImmediateKeyboardHelper(isFirstResponder: $isFirstResponder))
            .onAppear {
                isFirstResponder = true
            }
    }
}

struct ImmediateKeyboardHelper: UIViewRepresentable {
    
    @Binding private var isFirstResponder: Bool
    
    init(isFirstResponder: Binding<Bool>) {
        self._isFirstResponder = isFirstResponder
    }
    
    internal func updateUIView(_ uiView: UIViewType, context: Context) {
        if isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }
    
    internal func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isHidden = true
        return textView
    }
}

extension View {
    internal func immediateKeyboard() -> some View {
        self.modifier(ImmediateKeyboardModifier())
    }
}
