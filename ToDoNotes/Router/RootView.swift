//
//  RootView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import SwiftUI

struct RootView<Content: View>: View {
    
    @AppStorage(Texts.UserDefaults.theme) private var userTheme: Theme = .systemDefault
    @ViewBuilder internal var content: Content
    @State private var overlayWindow: UIWindow?
    
    internal var body: some View {
        content
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, overlayWindow == nil {
                    let window = PassthroughWindow(windowScene: windowScene)
                    window.backgroundColor = .clear
                    
                    let rootController = UIHostingController(rootView: ToastGroup()
                        .preferredColorScheme(userTheme.colorScheme))
                    rootController.view.frame = windowScene.keyWindow?.frame ?? .zero
                    rootController.view.backgroundColor = .clear
                    window.rootViewController = rootController
                    
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    window.tag = 1009
                    
                    overlayWindow = window
                }
            }
        
    }
}

fileprivate class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        
        return rootViewController?.view == view ? nil : view
    }
}
