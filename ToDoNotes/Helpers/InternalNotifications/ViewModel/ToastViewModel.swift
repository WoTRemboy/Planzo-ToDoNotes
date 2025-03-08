//
//  ToastViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import SwiftUI

@Observable
final class Toast {
    static let shared = Toast()
    internal var toasts: [ToastItem] = []
    
    internal func present(
        title: String, symbol: Image?,
        tint: Color = .BackColors.backPrimary,
        isUserInteractionEnabled: Bool = false,
        timing: ToastTime = .medium) {
            
            withAnimation(.snappy(duration: 0.3)) {
                toasts.append(.init(
                    title: title,
                    symbol: symbol,
                    tint: tint,
                    isUserInteractionEnabled: isUserInteractionEnabled,
                    timing: timing))
            }
        }
}
