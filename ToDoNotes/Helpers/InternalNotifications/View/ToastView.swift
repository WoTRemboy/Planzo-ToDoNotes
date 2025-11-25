//
//  Toast.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/7/25.
//

import SwiftUI

/// A view that displays a group of toast notifications stacked at the bottom of the screen.
struct ToastGroup: View {
    
    /// Shared toast model containing the list of active toasts.
    private var model = Toast.shared
    
    /// The main body of the ToastGroup view.
    internal var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            // ZStack to overlay multiple toasts, with each toast offset and scaled based on its position.
            ZStack {
                ForEach(model.toasts) { item in
                    ToastView(size: size, item: item)
                        .scaleEffect(scale(item)) // Scale toast based on its position in the stack.
                        .offset(y: offsetY(item)) // Vertical offset to create stacked appearance.
                        .zIndex(Double(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)) // Ensure correct stacking order.
                }
            }
            .padding(.bottom, safeArea.top == .zero ? 15 : 70)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Calculates the vertical offset for a toast based on its position in the stack.
    /// - Parameter item: The toast item to calculate offset for.
    /// - Returns: A CGFloat representing the vertical offset.
    private func offsetY(_ item: ToastItem) -> CGFloat {
        let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(model.toasts.count) - 1
        // If the toast is among the last two, offset by -20, else stagger by -10 per position.
        return (totalCount - index) >= 2 ? -20 : ((totalCount - index) * -10)
    }
    
    /// Calculates the scaling factor for a toast based on its position in the stack.
    /// - Parameter item: The toast item to calculate scale for.
    /// - Returns: A CGFloat representing the scale factor.
    private func scale(_ item: ToastItem) -> CGFloat {
        let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(model.toasts.count) - 1
        // If the toast is among the last two, scale down by 0.2, else scale down by 0.1 per position.
        return 1.0 - ((totalCount - index) >= 2 ? 0.2 : ((totalCount - index) * 0.1))
    }
}

/// A single toast view representing an individual toast notification.
private struct ToastView: View {
    /// Size of the parent container to limit the toast width.
    var size: CGSize
    /// The toast item data to display.
    var item: ToastItem
    
    /// A dispatch work item used to schedule automatic toast dismissal.
    @State private var delayTask: DispatchWorkItem?
    
    /// The main body of the ToastView.
    internal var body: some View {
        // Horizontal stack containing optional icon and title text.
        HStack(spacing: 0) {
            // Displays symbol image if provided.
            if let image = item.symbol {
                image
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 10)
            }
            
            // Displays the toast title text with styling.
            Text(item.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        
        .background(item.tint)
        .background(
            .background
                .shadow(.drop(color: .ShadowColors.popup,
                              radius: 32)),
            in: .rect(cornerRadius: 12)
        )
        .contentShape(.rect(cornerRadius: 12))
        
        // Gesture to allow user to drag the toast to dismiss it.
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    guard item.isUserInteractionEnabled else { return }
                    let endY = value.translation.height
                    let velocityY = value.velocity.height
                    
                    // If the drag gesture is sufficiently downward and fast, remove the toast.
                    if (endY + velocityY) > 100 {
                        removeToast()
                    }
                }
        )
        .onAppear {
            guard delayTask == nil else { return }
            delayTask = .init(block: {
                removeToast()
            })
            
            if let delayTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + item.timing.rawValue, execute: delayTask)
            }
        }
        // Limit the width of the toast relative to the parent size.
        .frame(maxWidth: size.width * 0.7)
        .transition(.scale)
    }
    
    // MARK: - Private Methods
    
    /// Removes the toast from the shared toast list with animation and cancels any scheduled dismissal.
    private func removeToast() {
        if let delayTask {
            delayTask.cancel()
        }
        withAnimation(.snappy(duration: 0.3)) {
            Toast.shared.toasts.removeAll(where: { $0.id == item.id })
        }
    }
}

// MARK: - Preview

#Preview {
    RootView {
        ContentView()
            .environmentObject(TabRouter())
            .environmentObject(AuthNetworkService())
    }
}
