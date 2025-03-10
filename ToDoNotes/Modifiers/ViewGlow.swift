//
//  ViewGlow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/6/25.
//

import SwiftUI

struct GlowAnimation: ViewModifier {
    @State private var animate = false
    
    internal func body(content: Content) -> some View {
        content
            .scaleEffect(animate ? 1.2 : 1.0)
            .shadow(color: Color.gray.opacity(animate ? 0.8 : 0.2),
                    radius: animate ? 15 : 5, x: 0, y: 0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
    }
}

struct Glow: ViewModifier {
    private let available: Bool
    
    init(available: Bool) {
        self.available = available
    }
    
    internal func body(content: Content) -> some View {
        if available {
            content.modifier(GlowAnimation())
        } else {
            content
        }
    }
}


extension View {
    internal func glow(available: Bool) -> some View {
        modifier(Glow(available: available))
    }
}
