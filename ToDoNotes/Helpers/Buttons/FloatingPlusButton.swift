//
//  FloatingPlusButton.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/25/26.
//

import SwiftUI

struct FloatingPlusButton: View {
    let action: () -> Void
    let namespace: Namespace.ID
    let glowAvailable: Bool
    let matchedGeometryID: String?

    internal var body: some View {
        Button {
            action()
        } label: {
            if #available(iOS 26.0, *) {
                glassContent
            } else {
                generalContent
            }
        }
        .navigationTransitionSource(id: Texts.NamespaceID.selectedEntity,
                                    namespace: namespace)
        .interactiveTintGlassIfAvailable(color: Color.LabelColors.labelPrimary)
        .matchedGeometryIfNeeded(id: matchedGeometryID, in: namespace)
        .glow(available: glowAvailable)
    }
    
    private var glassContent: some View {
        Image.TaskManagement.plus
            .resizable()
            .scaledToFit()
            .frame(width: 58, height: 58)
    }
    
    private var generalContent: some View {
        Circle()
            .fill(Color.LabelColors.labelPrimary)
            .frame(width: 58, height: 58)
            .overlay {
                Image.TaskManagement.plus
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
            }
    }
}

private extension View {
    @ViewBuilder
    func matchedGeometryIfNeeded(id: String?, in namespace: Namespace.ID) -> some View {
        if let id {
            self.matchedGeometryEffect(id: id, in: namespace)
        } else {
            self
        }
    }
}
