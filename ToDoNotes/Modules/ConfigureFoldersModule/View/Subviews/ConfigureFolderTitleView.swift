//
//  ConfigureFolderTitleView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 26/10/2025.
//

import SwiftUI

struct ConfigureFolderTitleView: View {
    // MARK: - Properties
    
    /// The title text displayed at the top of the alert.
    @State private var title: String = String()
    /// The action to perform when the primary button is tapped.
    private let primaryAction: (String) -> Void
    /// The action to perform when the secondary button is tapped.
    private let secondaryAction: () -> Void
    private let constantTitle: String
    
    @FocusState private var titleFocused: Bool
    @Binding var focusField: Bool

    @State private var isKeyboardActive = false
    @State private var keyboardWillShowObserver: NSObjectProtocol?
    @State private var keyboardWillHideObserver: NSObjectProtocol?
    
    // MARK: - Initializer
    
    /// Creates a new `CustomAlertView`.
    /// - Parameters:
    ///   - title: The alert's title text.
    ///   - focusField: Binding to control focus state externally.
    ///   - primaryAction: The closure to execute when the primary button is tapped.
    ///   - secondaryAction: A closure to execute when the secondary button is tapped.
    init(
        title: String?,
        focusField: Binding<Bool>,
        primaryAction: @escaping (String) -> Void,
        secondaryAction: @escaping () -> Void
    ) {
        if let title {
            self.title = title
        }
        self.constantTitle = title ?? Texts.Folders.Configure.newFolder
        self._focusField = focusField
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
    // MARK: - Body
    
    /// The main view body of the alert, containing the text and buttons.
    internal var body: some View {
        VStack(spacing: 20) {
            textBlock
            buttons
        }
        .frame(width: 320)
        
        .background(Color.BackColors.backSecondary)
        .cornerRadius(12)
        .shadow(radius: 10)
        
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isKeyboardActive)
        
        .focused($titleFocused)
        .immediateKeyboard(delay: 0)
        .onAppear {
            subscribeToKeyboardNotifications()
            titleFocused = true
        }
        
        .onDisappear {
            unsubscribeFromKeyboardNotifications()
        }
        .onChange(of: focusField) { _, newValue in
            titleFocused = newValue
        }
        .onChange(of: titleFocused) { oldValue, newValue in
            if oldValue != newValue {
                focusField = newValue
            }
        }
    }
    
    // MARK: - Components
    
    /// Builds the text block containing the title and optional message.
    private var textBlock: some View {
        VStack(spacing: 12) {
            Text(Texts.Folders.Configure.changeName)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .multilineTextAlignment(.center)
            
            TextField(constantTitle, text: $title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .padding(.horizontal)
                .padding(.vertical, 10)
            
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.SupportColors.supportTextField)
                )
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
    
    /// Builds the horizontal stack of buttons, including secondary (if any) and primary buttons.
    private var buttons: some View {
        HStack(spacing: 8) {
            secondaryButton
            primaryButton
        }
        .padding([.bottom, .horizontal], 6)
    }
    
    /// Builds the primary button with its action and styling.
    private var primaryButton: some View {
        Button {
            primaryAction(title)
            titleFocused = false
            focusField = false
        } label: {
            Text(Texts.Folders.Configure.save)
                .font(.system(size: 17, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: 50)
                .foregroundColor(Color.LabelColors.labelReversed)
                .background(Color.LabelColors.labelPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    /// Builds the secondary button with its action and styling.
    private var secondaryButton: some View {
        Button {
            secondaryAction()
            titleFocused = false
            focusField = false
        } label: {
            Text(Texts.Folders.Configure.cancel)
                .font(.system(size: 17, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.clear)
                .foregroundColor(Color.LabelColors.labelPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.LabelColors.labelDetails, lineWidth: 1)
                )
        }
    }
    
    private func subscribeToKeyboardNotifications() {
        keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            isKeyboardActive = true
        }
        keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            isKeyboardActive = false
        }
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        if let observer = keyboardWillShowObserver {
            NotificationCenter.default.removeObserver(observer)
            keyboardWillShowObserver = nil
        }
        if let observer = keyboardWillHideObserver {
            NotificationCenter.default.removeObserver(observer)
            keyboardWillHideObserver = nil
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var focusField: Bool = false
        
        var body: some View {
            ConfigureFolderTitleView(
                title: nil,
                focusField: $focusField,
                primaryAction: { _ in },
                secondaryAction: {}
            )
        }
    }
    return PreviewWrapper()
}

