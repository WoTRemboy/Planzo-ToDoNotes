//
//  PopView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/4/25.
//

import SwiftUI

struct Config {
    var backgroundColor: Color = .black.opacity(0.3)
}

extension View {
    @ViewBuilder
    internal func popView<Content: View>(
        config: Config = .init(),
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> (),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .modifier(
                PopViewHelper(
                    viewContent: content,
                    isPresented: isPresented,
                    config: config,
                    onDismiss: onDismiss))
    }
}

fileprivate struct PopViewHelper<ViewContent: View>: ViewModifier {
    @ViewBuilder var viewContent: ViewContent
    @Binding var isPresented: Bool
    
    var config: Config
    var onDismiss: () -> ()
    
    @State private var presentFullScreenCover: Bool = false
    @State private var animateView: Bool = false
    
    func body(content: Content) -> some View {
        let screenHeight = screenSize.height
        let animateView = animateView
        
        content
            .fullScreenCover(
                isPresented: $presentFullScreenCover,
                onDismiss: onDismiss) {
                    ZStack {
                        Rectangle()
                            .fill(config.backgroundColor)
                            .ignoresSafeArea()
                            .opacity(animateView ? 1 : 0)
                            .onTapGesture {
                                isPresented = false
                            }
                        
                        viewContent
                            .visualEffect({ content, proxy in
                                content
                                    .offset(y: offset(
                                        proxy,
                                        screenHeight: screenHeight,
                                        animateView: animateView))
                            })
                            .presentationBackground(.clear)
                            .task {
                                guard !animateView else { return }
                                withAnimation(.snappy(duration: 0.3)) {
                                    self.animateView = true
                                }
                            }
                            .ignoresSafeArea(.container, edges: .all)
                    }
                }
                .onChange(of: isPresented) { _, newValue in
                    if newValue {
                        toggleView(true)
                    } else {
                        Task {
                            withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                                self.animateView = false
                            }
                            try? await Task.sleep(for: .seconds(0.35))
                            
                            toggleView(false)
                        }
                    }
                }
    }
    
    nonisolated private func offset(_ proxy: GeometryProxy, screenHeight: CGFloat, animateView: Bool) -> CGFloat {
        let viewHeight = proxy.size.height
        return animateView ? 0 : (screenHeight + viewHeight) / 2
    }
    
    private func toggleView(_ status: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            presentFullScreenCover = status
        }
    }
    
    private var screenSize: CGSize {
        if let screenSize = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return screenSize
        }
        return .zero
    }
    
}

#Preview {
    ContentView()
}
