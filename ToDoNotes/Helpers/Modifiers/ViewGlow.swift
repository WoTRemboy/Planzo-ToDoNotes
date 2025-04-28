//
//  ViewGlow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/6/25.
//

import SwiftUI

// MARK: - Glow Animation

/// A view modifier that applies a pulsating glow animation to the content.
struct GlowAnimation: ViewModifier {
    /// Controls the animation state, toggling between scaled and normal size to create the glow effect.
    @State private var animate = false
    
    internal func body(content: Content) -> some View {
        content
            // Scales the view up when animating to create a pulsating effect.
            .scaleEffect(animate ? 1.2 : 1.0)
            // Applies a shadow with varying opacity and radius to simulate the glow.
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

// MARK: - Glow

/// A view modifier that conditionally applies the `GlowAnimation` based on the availability flag.
struct Glow: ViewModifier {
    /// Flag indicating whether the glow animation should be applied.
    private let available: Bool
    
    init(available: Bool) {
        self.available = available
    }
    
    /// Applies the glow animation modifier if `available` is true.
    internal func body(content: Content) -> some View {
        if available {
            content.modifier(GlowAnimation())
        } else {
            content
        }
    }
}

// MARK: - Extension

extension View {
    /// Provides a convenient method for applying the glow effect.
    /// - Parameter available: A Boolean value that determines whether the glow animation is applied.
    /// - Returns: A view that conditionally applies a glowing animation effect.
    internal func glow(available: Bool) -> some View {
        modifier(Glow(available: available))
    }
}
