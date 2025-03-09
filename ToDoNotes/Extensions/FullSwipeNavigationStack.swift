//
//  FullSwipeNavigationStack.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/3/25.
//

import SwiftUI

struct FullSwipeNavigationStack<Content: View>: View {
    @ViewBuilder var content: Content
    
    @State private var customGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.name = UUID().uuidString
        gesture.isEnabled = false
        return gesture
    }()
    
    internal var body: some View {
        NavigationStack {
            content
                .background {
                    AttachGestureView(gesture: $customGesture)
                }
        }
        .environment(\.popGestureID, customGesture.name)
        .onReceive(NotificationCenter.default.publisher(for: .init(customGesture.name ?? ""))) { info in
            if let userInfo = info.userInfo, let status = userInfo["status"] as? Bool {
                customGesture.isEnabled = status
            }
        }
    }
}

#Preview {
    ContentView()
//        .environmentObject(CoreDataViewModel())
}

fileprivate struct AttachGestureView: UIViewRepresentable {
    @Binding private var gesture: UIPanGestureRecognizer
    
    init(gesture: Binding<UIPanGestureRecognizer>) {
        self._gesture = gesture
    }
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let parentViewController = uiView.parentViewController {
                if let navigationController = parentViewController.navigationController {
                    if let _ = navigationController.view.gestureRecognizers?.first(where: { $0.name == gesture.name }) {
                        print("Navigation Back Gesture already attached")
                    } else {
                        navigationController.addFullSwipeGesture(gesture)
                        print("Navigation Back Gesture attached")
                    }
                }
            }
        }
    }
}

fileprivate struct PopNotificationID: EnvironmentKey {
    static var defaultValue: String?
}

fileprivate extension EnvironmentValues {
    var popGestureID: String? {
        get {
            self[PopNotificationID.self]
        }
        set {
            self[PopNotificationID.self] = newValue
        }
    }
}

extension View {
    @ViewBuilder
    func enableFullSwipePop(_ isEnabled: Bool) -> some View {
        self
            .modifier(FullSwipeModifier())
    }
}


fileprivate struct FullSwipeModifier: ViewModifier {
    @Environment(\.popGestureID) private var gestureID
    func body(content: Content) -> some View {
        content
            .onAppear() {
                guard let gestureID = gestureID else { return }
                NotificationCenter.default.post(name: .init(gestureID), object: nil, userInfo: [
                    "status": true
                ])
            }
            .onDisappear {
                guard let gestureID = gestureID else { return }
                NotificationCenter.default.post(name: .init(gestureID), object: nil, userInfo: [
                    "status": false
                ])
            }
    }
}

fileprivate extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) {
            $0.next
        }.first(where: { $0 is UIViewController }) as? UIViewController
    }
}

fileprivate extension UINavigationController {
    func addFullSwipeGesture(_ gesture: UIPanGestureRecognizer) {
        guard let gestureSelector = interactivePopGestureRecognizer?.value(forKey: "targets") else { return }
        
        gesture.setValue(gestureSelector, forKey: "targets")
        view.addGestureRecognizer(gesture)
    }
}
