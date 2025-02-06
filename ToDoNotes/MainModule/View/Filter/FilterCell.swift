//
//  FilterCell.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct FilterCell: View {
        
    private let selected: Bool
    private let name: String
    private let namespace: Namespace.ID
    
    init(name: String, selected: Bool, namespace: Namespace.ID) {
        self.name = name
        self.selected = selected
        self.namespace = namespace
    }
    
    internal var body: some View {
        nameLabel
            .background(alignment: .bottom) {
                if selected {
                    underline
                        .offset(y: 5)
                }
            }
    }
    
    private var nameLabel: some View {
        Text(name)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(selected ? Color.LabelColors.labelPrimary : Color.LabelColors.labelSecondary)
            .frame(maxWidth: .infinity)
    }
    
    private var underline: some View {
        Rectangle()
            .foregroundStyle(Color.LabelColors.labelPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 2)
            .matchedGeometryEffect(id: Texts.NamespaceID.selectedTab, in: namespace)
    }
}

#Preview {
    FilterCell(name: "Active", selected: true, namespace: Namespace().wrappedValue)
}
