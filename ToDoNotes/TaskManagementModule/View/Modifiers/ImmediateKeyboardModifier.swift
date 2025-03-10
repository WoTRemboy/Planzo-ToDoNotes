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
    private let delay: Double
    
    init(delay: Double) {
        self.delay = delay
    }
    
    internal func body(content: Content) -> some View {
        content
            .background(ImmediateKeyboardHelper(
                isFirstResponder: $isFirstResponder,
                delay: delay))
            .onAppear {
                withAnimation {
                    isFirstResponder = true
                }
            }
    }
}

struct ImmediateKeyboardHelper: UIViewRepresentable {
    
    @Binding private var isFirstResponder: Bool
    private let delay: Double
    
    init(isFirstResponder: Binding<Bool>, delay: Double) {
        self._isFirstResponder = isFirstResponder
        self.delay = delay
    }
    
    internal func updateUIView(_ uiView: UIViewType, context: Context) {
        if isFirstResponder {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                uiView.becomeFirstResponder()
            }
        }
    }
    
    internal func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isHidden = true
        return textView
    }
}

extension View {
    internal func immediateKeyboard(delay: Double) -> some View {
        self.modifier(ImmediateKeyboardModifier(delay: delay))
    }
}
