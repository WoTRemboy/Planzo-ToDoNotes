//
//  NavigationTransitionModifier.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/22/25.
//

import SwiftUI

struct NavigationTransitionModifier: ViewModifier {
    private let id: String
    private let namespace: Namespace.ID
    private let enable: Bool
    
    init(id: String, namespace: Namespace.ID, enable: Bool) {
        self.id = id
        self.namespace = namespace
        self.enable = enable
    }
    
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

struct NavigationTransitionSourceModifier: ViewModifier {
    private let id: String
    private let namespace: Namespace.ID
    
    init(id: String, namespace: Namespace.ID) {
        self.id = id
        self.namespace = namespace
    }
    
    internal func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .matchedTransitionSource(id: id, in: namespace)
        } else {
            content
        }
    }
}

extension View {
    internal func navigationTransition(id: String, namespace: Namespace.ID, enable: Bool) -> some View {
        self.modifier(NavigationTransitionModifier(id: id, namespace: namespace, enable: enable))
    }
    
    internal func navigationTransitionSource(id: String, namespace: Namespace.ID) -> some View {
        self.modifier(NavigationTransitionSourceModifier(id: id, namespace: namespace))
    }
}
