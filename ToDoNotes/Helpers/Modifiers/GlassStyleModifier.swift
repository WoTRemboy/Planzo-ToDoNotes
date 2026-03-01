//
//  GlassStyleModifier.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/25/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func glassStyleIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func interactiveGlassIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive())
        } else {
            self
        }
    }
    
    @ViewBuilder
    func interactiveTintGlassIfAvailable(color: Color) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(color).interactive())
        } else {
            self
        }
    }
}
