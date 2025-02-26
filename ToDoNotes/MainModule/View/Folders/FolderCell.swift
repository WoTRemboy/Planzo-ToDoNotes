//
//  FolderCell.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct FolderCell: View {
    
    private let name: String
    private let color: Color
    private let selected: Bool
    private let namespace: Namespace.ID
    
    init(name: String, color: Color,
         selected: Bool, namespace: Namespace.ID) {
        self.name = name
        self.color = color
        self.selected = selected
        self.namespace = namespace
    }
    
    internal var body: some View {
        ZStack {
            if selected {
                backgroundRectangle
            } else {
                emptyRectangle
            }
            
            nameLabel
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
        }
    }
    
    private var nameLabel: some View {
        Text(name)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(selected ? Color.white : Color.LabelColors.labelSecondary)
            .background(alignment: .bottom) {
                underline
                    .offset(y: 4)
            }
    }
    
    private var underline: some View {
        Rectangle()
            .foregroundStyle(selected ? .clear : color)
        
            .frame(maxWidth: .infinity)
            .frame(height: 4)
            .clipShape(.rect(cornerRadius: 3))
    }
    
    private var backgroundRectangle: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(selected ? color : .clear)
            .matchedGeometryEffect(id: Texts.NamespaceID.selectedTab, in: namespace)
            .transition(.opacity)
    }
    
    private var emptyRectangle: some View {
        Rectangle()
            .foregroundStyle(Color.clear)
    }
}

#Preview {
    FolderCell(name: "Passwords", color: Color.FolderColors.passwords,
               selected: true, namespace: Namespace().wrappedValue)
}
