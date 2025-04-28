//
//  NavigationTransitionModifier.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/22/25.
//

import SwiftUI

// MARK: - Navigation Transition Modifier

/// A view modifier that applies a zoom-based navigation transition using a matched namespace ID.
struct NavigationTransitionModifier: ViewModifier {
    
    // MARK: - Properties
    
    /// The unique ID for the transition source.
    private let id: String
    /// The namespace used for matched transitions.
    private let namespace: Namespace.ID
    /// A Boolean value that determines whether to apply the transition.
    private let enable: Bool
    
    // MARK: - Initialization
    
    /// Initializes the NavigationTransitionModifier.
    ///
    /// - Parameters:
    ///   - id: The unique ID for the transition source.
    ///   - namespace: The namespace used for matched transitions.
    ///   - enable: A Boolean value that determines whether to apply the transition.
    init(id: String, namespace: Namespace.ID, enable: Bool) {
        self.id = id
        self.namespace = namespace
        self.enable = enable
    }
    
    // MARK: - Body
    
    internal func body(content: Content) -> some View {
        if #available(iOS 18.0, *), enable {
            content
                .navigationTransition(
                    .zoom(sourceID: id,
                          in: namespace))
        } else {
            content
        }
    }
}

// MARK: - Navigation Transition Source Modifier

/// A view modifier that marks a view as the source of a matched navigation transition.
struct NavigationTransitionSourceModifier: ViewModifier {
    
    // MARK: - Properties
    
    /// The unique ID for the source view.
    private let id: String
    /// The namespace for the transition.
    private let namespace: Namespace.ID
    
    // MARK: - Initialization
    
    /// Initializes the NavigationTransitionSourceModifier.
    ///
    /// - Parameters:
    ///   - id: The unique ID for the source view.
    ///   - namespace: The namespace for the transition.
    init(id: String, namespace: Namespace.ID) {
        self.id = id
        self.namespace = namespace
    }
    
    // MARK: - Body
    
    internal func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .matchedTransitionSource(id: id, in: namespace)
        } else {
            content
        }
    }
}

// MARK: - View Extension

extension View {
    
    /// Applies a navigation transition modifier to the view.
    /// - Parameters:
    ///   - id: A unique identifier for the transition source.
    ///   - namespace: The namespace associated with the transition.
    ///   - enable: A Boolean flag that enables or disables the transition.
    /// - Returns: A view with the navigation transition applied.
    internal func navigationTransition(id: String, namespace: Namespace.ID, enable: Bool) -> some View {
        self.modifier(NavigationTransitionModifier(id: id, namespace: namespace, enable: enable))
    }
    
    /// Marks the view as a transition source using a matched geometry effect.
    /// - Parameters:
    ///   - id: A unique identifier for the source.
    ///   - namespace: The namespace used for the transition.
    /// - Returns: A view marked as the transition source.
    internal func navigationTransitionSource(id: String, namespace: Namespace.ID) -> some View {
        self.modifier(NavigationTransitionSourceModifier(id: id, namespace: namespace))
    }
}
