//
//  ToastModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import SwiftUI

// MARK: - Toast Item Model

/// A model representing a single toast notification.
///
/// Toasts are temporary pop-up messages that inform the user about an operation.
struct ToastItem: Identifiable {
    /// Unique identifier for the toast.
    let id: UUID = .init()
    /// Text content displayed inside the toast.
    var title: String
    /// Optional system image to accompany the text.
    var symbol: Image?
    /// Color of the symbol and text.
    var tint: Color
    /// Boolean indicating whether the user can interact with the screen while the toast is shown.
    var isUserInteractionEnabled: Bool
    /// Duration for which the toast is displayed.
    var timing: ToastTime = .medium
}

// MARK: - Toast Time

/// Enum representing the display duration of a toast.
enum ToastTime: CGFloat {
    case short = 1.0    // short: 1 second
    case medium = 2.0   // medium: 2 seconds (default)
    case long = 3.5     // long: 3.5 seconds
}
