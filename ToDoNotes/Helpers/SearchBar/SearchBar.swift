//
//  SearchBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/7/25.
//

import SwiftUI

/// A reusable search bar component with a text field, clear button, and cancel button.
struct SearchBar: View {
    
    // MARK: - Properties
    
    /// Binding to the search text string entered by the user.
    @Binding private var text: String
    
    /// Focus state to manage the keyboard focus on the search text field.
    @FocusState private var isFocused: Bool
    @State private var showCancelButtonIOS26: Bool = false
    @Namespace private var glassNamespace
    
    /// Closure to be called when the cancel button is tapped.
    private var onCancel: () -> Void
    
    // MARK: - Initialization
    
    /// Initializes the SearchBar with a binding to the search text and a cancel action.
    /// - Parameters:
    ///   - text: A binding to the search text string.
    ///   - onCancel: A closure that is called when the cancel button is tapped.
    init(text: Binding<String>, onCancel: @escaping () -> Void) {
        self._text = text
        self.onCancel = onCancel
    }

    // MARK: - Body
    
    /// The main view body containing the search text field and the cancel button.
    internal var body: some View {
        // Horizontal stack containing the search text field and the cancel button
        Group {
            if #available(iOS 26.0, *) {
                searchContainerIOS26
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                        showCancelButtonIOS26 = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showCancelButtonIOS26 = true
                            }
                        }
                    }
                    .onDisappear {
                        clearTextField()
                        showCancelButtonIOS26 = false
                    }
            } else {
                HStack(spacing: 0) {
                    // Search text field with clear button overlay
                    searchTextField
                        .focused($isFocused)
                        .onAppear {
                            isFocused = true
                        }
                        .onDisappear {
                            clearTextField()
                        }
                    
                    // Cancel button to dismiss the search
                    cancelButton
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Subviews
    
    /// The search text field view with a magnifying glass icon and a clear button when text is not empty.
    private var searchTextField: some View {
        // TextField with placeholder and styling
        TextField(Texts.SearchBar.placeholder, text: $text)
            .font(.system(size: 17, weight: .regular))
            .padding(8)
            .padding(.horizontal, 25)
        
            .background(Color.SupportColors.supportTextField)
            .cornerRadius(10)
        
            // Overlay containing the magnifying glass icon and clear button
            .overlay(
                HStack(spacing: 0) {
                    // Magnifying glass icon on the left
                    Image.NavigationBar.SearchBar.glass
                        .padding(.leading, 8)
                    Spacer()
                    // Clear button on the right, shown only if text is not empty
                    if !text.isEmpty {
                        clearButton
                    }
                }
            )
    }
    
    /// The clear button that clears the search text when tapped.
    private var clearButton: some View {
        // Button to clear the text field with animation and refocus
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                clearTextField()
                isFocused = true
            }
        } label: {
            Image.NavigationBar.SearchBar.clear
        }
        .padding(.trailing, 6)
    }
    
    /// The cancel button that dismisses the keyboard and triggers the cancel action.
    private var cancelButton: some View {
        // Button to cancel the search with animation and keyboard dismissal
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                dismissKeyboard()
                onCancel()
            }
        } label: {
            Text(Texts.SearchBar.cancel)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.LabelColors.Special.labelSearchBarCancel)
        }
        .transition(.move(edge: .trailing))
        .padding(.leading)
    }
    
    /// The search text field style for iOS 26+ (Liquid Glass).
    @available(iOS 26.0, *)
    private var searchTextFieldIOS26: some View {
        HStack(spacing: 8) {
            Image.NavigationBar.SearchBar.glass
                .padding(.leading, 10)
            TextField(Texts.SearchBar.placeholder, text: $text)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .overlay(alignment: .trailing) {
                    if !text.isEmpty {
                        clearButton
                            .padding(.trailing, 8)
                    }
                }
        }
        .glassEffectID("searchTextField", in: glassNamespace)
        .frame(maxHeight: .infinity)
        .glassEffect(.regular.interactive())
    }

    /// The combined container for iOS 26+ search field and cancel button.
    @available(iOS 26.0, *)
    private var searchContainerIOS26: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                searchTextFieldIOS26
                if showCancelButtonIOS26 {
                    cancelButtonIOS26
                }
            }
            .frame(height: 44)
        }
    }

    /// The cancel button for iOS 26+ (Liquid Glass, circular).
    @available(iOS 26.0, *)
    private var cancelButtonIOS26: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                dismissKeyboard()
                onCancel()
            }
        } label: {
            Image.Settings.Passcode.close
                .resizable()
                .scaledToFit()
                .padding(8)
                .frame(maxHeight: .infinity)
        }
        .glassEffectID("searchCancel", in: glassNamespace)
        .glassEffect(.regular.interactive())
    }
}

// MARK: - Private Methods

extension SearchBar {
    /// Clears the search text with an animation.
    private func clearTextField() {
        withAnimation(.easeInOut(duration: 0.2)) {
            text = String()
        }
    }
    
    /// Dismisses the keyboard by removing the focus from the text field.
    private func dismissKeyboard() {
        isFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview

#Preview {
    SearchBar(text: .constant("Hello"), onCancel: {})
}
