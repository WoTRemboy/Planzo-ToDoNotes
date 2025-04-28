//
//  RootViewControllerMethods.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/12/25.
//

import UIKit

/// A utility class providing methods to access the root and visible view controllers in the app's scene hierarchy.
final class RootViewControllerMethods {
    
    // MARK: - Public Methods
    
    /// Retrieves the currently visible view controller from the application's main window.
    /// - Returns: The currently visible `UIViewController` if available, otherwise `nil`.
    static func getRootViewController() -> UIViewController? {
        // Attempt to get the first connected UIWindowScene
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            return nil
        }
        // Recursively finds the currently visible view controller starting from the root
        return getVisibleViewController(from: rootViewController)
    }

    /// Recursively retrieves the visible view controller from the given view controller.
    /// - Parameter vc: The starting `UIViewController`.
    /// - Returns: The currently visible `UIViewController`.
    static func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        // If the view controller is a UINavigationController, follow its visibleViewController
        if let nav = vc as? UINavigationController {
            return getVisibleViewController(from: nav.visibleViewController!)
        }
        
        // If the view controller is a UITabBarController, follow its selectedViewController
        if let tab = vc as? UITabBarController {
            return getVisibleViewController(from: tab.selectedViewController!)
        }
        
        // If the view controller presented another view controller, follow the presented one
        if let presented = vc.presentedViewController {
            return getVisibleViewController(from: presented)
        }
        
        // If none of the above, return the current view controller
        return vc
    }

}
