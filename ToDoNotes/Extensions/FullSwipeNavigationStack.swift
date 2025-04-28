//
//  FullSwipeNavigationStack.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/3/25.
//

import SwiftUI
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.extensions", category: "FullSwipeNavigationStack")

// MARK: - Full Swipe Navigation Stack

/// A navigation stack view that enables a custom full-screen swipe gesture for navigation pop.
struct FullSwipeNavigationStack<Content: View>: View {
    /// The content to be displayed inside the navigation stack.
    @ViewBuilder var content: Content
    
    /// The custom pan gesture recognizer used for full swipe pop.
    @State private var customGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.name = UUID().uuidString // Assign a unique name to identify the gesture.
        gesture.isEnabled = false // Initially disabled; enabled via notifications.
        return gesture
    }()
    
    /// The view body that sets up the navigation stack and attaches gesture logic.
    internal var body: some View {
        NavigationStack {
            content
                .background {
                    AttachGestureView(gesture: $customGesture)
                }
        }
        .environment(\.popGestureID, customGesture.name)
        .onReceive(NotificationCenter.default.publisher(for: .init(customGesture.name ?? ""))) { info in
            // Listens for notifications to enable/disable the custom gesture.
            if let userInfo = info.userInfo, let status = userInfo["status"] as? Bool {
                customGesture.isEnabled = status
            }
        }
    }
}

// MARK: - Attach Gesture View

/// A view that attaches a custom pan gesture to the navigation controller.
fileprivate struct AttachGestureView: UIViewRepresentable {
    /// The gesture recognizer to attach.
    @Binding private var gesture: UIPanGestureRecognizer
    
    /// Initializes with a binding to the gesture recognizer.
    /// - Parameter gesture: A binding to the custom pan gesture recognizer.
    init(gesture: Binding<UIPanGestureRecognizer>) {
        self._gesture = gesture
    }
    
    /// Creates the underlying UIView.
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    /// Attaches the gesture to the navigation controller's view if not already attached.
    func updateUIView(_ uiView: UIView, context: Context) {
        // Delays to ensure the view hierarchy is available.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let parentViewController = uiView.parentViewController {
                if let navigationController = parentViewController.navigationController {
                    // Checks if the gesture is already attached.
                    if let _ = navigationController.view.gestureRecognizers?.first(where: { $0.name == gesture.name }) {
                        logger.warning("Navigation Back Gesture already attached")
                    } else {
                        navigationController.addFullSwipeGesture(gesture)
                        logger.debug("Navigation Back Gesture attached.")
                    }
                }
            }
        }
    }
}

// MARK: - Pop Notification ID

/// An environment key for passing the custom gesture's notification ID.
fileprivate struct PopNotificationID: EnvironmentKey {
    /// The default value for the environment key.
    static var defaultValue: String?
}

// MARK: - EnvironmentValues + PopGestureID

/// An extension to EnvironmentValues to store and access the pop gesture notification ID.
fileprivate extension EnvironmentValues {
    /// The notification ID for the pop gesture.
    var popGestureID: String? {
        get {
            self[PopNotificationID.self]
        }
        set {
            self[PopNotificationID.self] = newValue
        }
    }
}

// MARK: - View + FullSwipePop

/// An extension on View to enable the full swipe pop gesture via a modifier.
extension View {
    /// Enables the full swipe pop gesture for this view.
    /// - Parameter isEnabled: Whether the gesture should be enabled (currently ignored).
    func enableFullSwipePop(_ isEnabled: Bool) -> some View {
        self
            .modifier(FullSwipeModifier())
    }
}

// MARK: - Full Swipe Modifier

/// A view modifier that posts notifications to enable or disable the custom swipe gesture.
fileprivate struct FullSwipeModifier: ViewModifier {
    /// The gesture notification ID from the environment.
    @Environment(\.popGestureID) private var gestureID
    
    /// Posts notifications on appear/disappear to control the gesture's enabled state.
    func body(content: Content) -> some View {
        content
            .onAppear() {
                // Enables the gesture when the view appears.
                guard let gestureID = gestureID else { return }
                NotificationCenter.default.post(name: .init(gestureID), object: nil, userInfo: [
                    "status": true
                ])
            }
            .onDisappear {
                // Disables the gesture when the view disappears.
                guard let gestureID = gestureID else { return }
                NotificationCenter.default.post(name: .init(gestureID), object: nil, userInfo: [
                    "status": false
                ])
            }
    }
}

// MARK: - UIView + ParentViewController

/// An extension to UIView to find the nearest parent UIViewController.
fileprivate extension UIView {
    /// Returns the nearest parent view controller in the responder chain.
    var parentViewController: UIViewController? {
        // Traverses the responder chain to find a UIViewController.
        sequence(first: self) {
            $0.next
        }.first(where: { $0 is UIViewController }) as? UIViewController
    }
}

// MARK: - UINavigationController + FullSwipeGesture

/// An extension to UINavigationController to add a custom full swipe gesture for pop.
fileprivate extension UINavigationController {
    /// Adds the provided pan gesture recognizer as a full swipe pop gesture.
    /// - Parameter gesture: The custom pan gesture recognizer to be added.
    func addFullSwipeGesture(_ gesture: UIPanGestureRecognizer) {
        // Copies the internal targets from the system's interactivePopGestureRecognizer.
        guard let gestureSelector = interactivePopGestureRecognizer?.value(forKey: "targets") else { return }
        
        gesture.setValue(gestureSelector, forKey: "targets")
        view.addGestureRecognizer(gesture)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
