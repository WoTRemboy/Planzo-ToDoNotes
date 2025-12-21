//
//  LoadingOverlay.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 15/09/2025.
//

import SwiftUI

final class LoadingOverlay: ObservableObject {
    static let shared = LoadingOverlay()
    @Published var isVisible: Bool = false
    
    internal func show() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isVisible = true
            }
        }
    }
    
    internal func hide() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.isVisible = false
            }
        }
    }
}

struct LoadingOverlayGroup: View {
    @ObservedObject private var overlay = LoadingOverlay.shared
    
    internal var body: some View {
        Group {
            if overlay.isVisible {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .overlay(
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.backSheet)
                                .frame(width: 60, height: 60)
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(1.6)
                        }
                    )
                    .transition(.opacity)
            }
        }
        .allowsHitTesting(overlay.isVisible)
        .animation(.easeInOut, value: overlay.isVisible)
        .onChange(of: overlay.isVisible) { _, newValue in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows where window.tag == 1010 {
                    window.isUserInteractionEnabled = newValue
                }
            }
        }
        .onAppear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows where window.tag == 1010 {
                    window.isUserInteractionEnabled = overlay.isVisible
                }
            }
        }
        .onDisappear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows where window.tag == 1010 {
                    window.isUserInteractionEnabled = false
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.green.ignoresSafeArea()
        LoadingOverlayGroup()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    LoadingOverlay.shared.show()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        LoadingOverlay.shared.hide()
                    }
                }
            }
    }
}
