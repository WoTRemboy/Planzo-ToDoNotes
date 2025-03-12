//
//  SearchBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/7/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding private var text: String
    @FocusState private var isFocused: Bool
    
    private var onCancel: () -> Void
    
    init(text: Binding<String>, onCancel: @escaping () -> Void) {
        self._text = text
        self.onCancel = onCancel
    }

    internal var body: some View {
        HStack(spacing: 0) {
            searchTextField
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
                .onDisappear {
                    clearTextField()
                }
            
            cancelButton
        }
        .padding(.horizontal)
    }
    
    private var searchTextField: some View {
        TextField(Texts.SearchBar.placeholder, text: $text)
            .font(.system(size: 17, weight: .regular))
        
            .padding(8)
            .padding(.horizontal, 25)
            .background(Color.SupportColors.supportTextField)
            .cornerRadius(10)
        
            .overlay(
                HStack(spacing: 0) {
                    Image.NavigationBar.SearchBar.glass
                        .padding(.leading, 8)
                    Spacer()
                    if !text.isEmpty {
                        clearButton
                    }
                }
            )
    }
    
    private var clearButton: some View {
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
    
    private var cancelButton: some View {
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
}

#Preview {
    SearchBar(text: .constant("Hello"), onCancel: {})
}

extension SearchBar {
    private func clearTextField() {
        withAnimation(.easeInOut(duration: 0.2)) {
            text = String()
        }
    }
    
    private func dismissKeyboard() {
        isFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
