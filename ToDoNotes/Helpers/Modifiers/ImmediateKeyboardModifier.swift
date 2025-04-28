//
//  ImmediateKeyboardModifier.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/20/25.
//

import SwiftUI
import UIKit

// MARK: - Immediate Keyboard Modifier

/// A view modifier that automatically brings up the keyboard with a specified delay when the view appears.
struct ImmediateKeyboardModifier: ViewModifier {
    
    // MARK: - Properties
    
    /// Tracks whether the view should become the first responder.
    @State private var isFirstResponder: Bool = false
    
    /// The delay before showing the keyboard, in seconds.
    private let delay: Double
    
    // MARK: - Initialization
    
    /// Initializes the ImmediateKeyboardModifier.
    /// - Parameter delay: The delay before the keyboard appears.
    init(delay: Double) {
        self.delay = delay
    }
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .background(
                ImmediateKeyboardHelper(
                    isFirstResponder: $isFirstResponder,
                    delay: delay
                )
            )
            .onAppear {
                withAnimation {
                    isFirstResponder = true
                }
            }
    }
}

// MARK: - Immediate Keyboard Helper

/// A helper UIViewRepresentable that triggers the keyboard appearance by using a hidden UITextView.
struct ImmediateKeyboardHelper: UIViewRepresentable {
    
    // MARK: - Properties
    
    /// Binding to track when to become the first responder.
    @Binding private var isFirstResponder: Bool
    
    /// The delay before becoming first responder.
    private let delay: Double
    
    // MARK: - Initialization
    
    /// Initializes the ImmediateKeyboardHelper.
    /// - Parameters:
    ///   - isFirstResponder: A binding to trigger first responder activation.
    ///   - delay: Delay before becoming the first responder.
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

// MARK: - View Extension

extension View {
    
    /// A modifier that automatically shows the keyboard after a delay.
    ///
    /// - Parameter delay: The delay before the keyboard appears.
    /// - Returns: A view that automatically focuses and shows the keyboard.
    internal func immediateKeyboard(delay: Double) -> some View {
        self.modifier(ImmediateKeyboardModifier(delay: delay))
    }
}
