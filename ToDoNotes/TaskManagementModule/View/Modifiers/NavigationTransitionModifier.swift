//
//  NavigationTransitionModifier.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/22/25.
//

import SwiftUI

struct NavigationTransitionModifier: ViewModifier {
    private let id: UUID?
    private let namespace: Namespace.ID
    
    init(id: UUID?, namespace: Namespace.ID) {
        self.id = id
        self.namespace = namespace
    }
    
    internal func body(content: Content) -> some View {
        if #available(iOS 18.0, *), let id {
            content
                .navigationTransition(
                    .zoom(sourceID: "\(String(describing: id))",
                          in: namespace))
        } else {
            content
        }
    }
}

extension View {
    internal func navigationTransition(id: UUID?, namespace: Namespace.ID) -> some View {
        self.modifier(NavigationTransitionModifier(id: id, namespace: namespace))
    }
}
