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
    internal func body(content: Content) -> some View {
        TimelineView(.animation) { context in
            let duration = 2.0
            let phase = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: duration) / duration
            let eased = 0.5 - 0.5 * cos(phase * 2.0 * .pi)
            let scale = 1.0 + 0.2 * eased
            let shadowOpacity = 0.2 + 0.6 * eased
            let shadowRadius = 5.0 + 10.0 * eased
            
            content
                // Scales the view up when animating to create a pulsating effect.
                .scaleEffect(scale)
                // Applies a shadow with varying opacity and radius to simulate the glow.
                .shadow(color: Color.gray.opacity(shadowOpacityForCurrentOS(base: shadowOpacity)),
                        radius: shadowRadiusForCurrentOS(base: shadowRadius), x: 0, y: 0)
        }
    }
    
    private func shadowOpacityForCurrentOS(base: Double) -> Double {
        if #available(iOS 26.0, *) {
            return 0.0
        }
        return base
    }
    
    private func shadowRadiusForCurrentOS(base: Double) -> Double {
        if #available(iOS 26.0, *) {
            return 0.0
        }
        return base
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
