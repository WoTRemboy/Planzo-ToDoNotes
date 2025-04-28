//
//  HeightReader.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import SwiftUI

/// A utility view that reads its content height and updates a bound variable with it.
struct HeightReader: View {
    
    // MARK: - Properties
    
    /// A binding to a `CGFloat` value that will be updated with the view's height.
    @Binding private var height: CGFloat
    
    // MARK: - Initializer
    
    /// Initializes a new `HeightReader`.
    /// - Parameter height: A binding to a `CGFloat` value where the height will be stored.
    init(height: Binding<CGFloat>) {
        self._height = height
    }
    
    // MARK: - Body
    
    /// The content and behavior of the `HeightReader` view.
    ///
    /// Uses a `GeometryReader` to capture the view's size and updates the bound height on appear and on size changes.
    internal var body: some View {
        GeometryReader { geometry in
            // A transparent color to make the GeometryReader active without affecting layout.
            Color.clear
                .onAppear {
                    // Sets the initial height when the view appears.
                    height = geometry.size.height
                }
                .onChange(of: geometry.size.height) { _, newValue in
                    withAnimation {
                        height = newValue
                    }
                }
        }
    }
}
