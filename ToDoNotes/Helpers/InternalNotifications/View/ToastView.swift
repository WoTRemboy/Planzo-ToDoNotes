//
//  Toast.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/7/25.
//

import SwiftUI

struct ToastGroup: View {
    private var model = Toast.shared
    internal var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            ZStack {
                ForEach(model.toasts) { item in
                    ToastView(size: size, item: item)
                        .scaleEffect(scale(item))
                        .offset(y: offsetY(item))
                        .zIndex(Double(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0))
                }
            }
            .padding(.bottom, safeArea.top == .zero ? 15 : 70)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
    
    private func offsetY(_ item: ToastItem) -> CGFloat {
        let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(model.toasts.count) - 1
        return (totalCount - index) >= 2 ? -20 : ((totalCount - index) * -10)
    }
    
    private func scale(_ item: ToastItem) -> CGFloat {
        let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(model.toasts.count) - 1
        return 1.0 - ((totalCount - index) >= 2 ? 0.2 : ((totalCount - index) * 0.1))
    }
}

private struct ToastView: View {
    var size: CGSize
    var item: ToastItem
    
    @State private var delayTask: DispatchWorkItem?
    
    internal var body: some View {
        HStack(spacing: 0) {
            if let image = item.symbol {
                image
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 10)
            }
            
            Text(item.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .lineLimit(1)
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
        
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    guard item.isUserInteractionEnabled else { return }
                    let endY = value.translation.height
                    let velocityY = value.velocity.height
                    
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
        .frame(maxWidth: size.width * 0.7)
        .transition(.scale)
    }
    
    private func removeToast() {
        if let delayTask {
            delayTask.cancel()
        }
        withAnimation(.snappy(duration: 0.3)) {
            Toast.shared.toasts.removeAll(where: { $0.id == item.id })
        }
    }
}

#Preview {
    RootView {
        ContentView()
            .environmentObject(TabRouter())
    }
}
