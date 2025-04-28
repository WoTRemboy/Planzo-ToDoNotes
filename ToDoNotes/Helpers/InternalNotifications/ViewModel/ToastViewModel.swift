//
//  ToastViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import SwiftUI

/// A ViewModel responsible for managing and displaying toast notifications across the app.
@Observable
final class Toast {
    /// A shared singleton instance of the `Toast` ViewModel.
    static let shared = Toast()
    
    /// An array containing currently active toast notifications.
    internal var toasts: [ToastItem] = []
    
    /// Presents a new toast message by appending it to the `toasts` array.
    /// - Parameters:
    ///   - title: The main text to be displayed in the toast.
    ///   - symbol: An optional `Image` symbol shown alongside the title.
    ///   - tint: The color tint of the toast background (default is a support color).
    ///   - isUserInteractionEnabled: Determines if the toast allows user interaction (default is `false`).
    ///   - timing: The duration the toast stays visible (default is `.medium`).
    internal func present(
        title: String,
        symbol: Image? = nil,
        tint: Color = Color.SupportColors.supportPopup,
        isUserInteractionEnabled: Bool = false,
        timing: ToastTime = .medium
    ) {
        withAnimation(.snappy(duration: 0.3)) {
            toasts.append(
                .init(
                    title: title,
                    symbol: symbol,
                    tint: tint,
                    isUserInteractionEnabled: isUserInteractionEnabled,
                    timing: timing
                )
            )
        }
    }
}
