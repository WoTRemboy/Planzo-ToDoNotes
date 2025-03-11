//
//  FolderCell.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct FolderCell: View {
    
    private let folder: Folder
    private let selected: Bool
    private let namespace: Namespace.ID
    
    init(folder: Folder, selected: Bool, namespace: Namespace.ID) {
        self.folder = folder
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
        let color: Color
        if selected && folder == .all {
            color = Color.white
        } else if selected {
            color = Color.LabelColors.labelPrimary
        } else {
            color = Color.LabelColors.labelSecondary
        }
        
        return Text(folder.name)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(color)
            .background(alignment: .bottom) {
                underline
                    .offset(y: 4)
            }
    }
    
    private var underline: some View {
        Rectangle()
            .foregroundStyle(selected ? .clear : folder.color)
        
            .frame(maxWidth: .infinity)
            .frame(height: 4)
            .clipShape(.rect(cornerRadius: 3))
    }
    
    private var backgroundRectangle: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(selected ? folder.color : .clear)
            .animation(.easeInOut(duration: 0.2), value: selected)
            .matchedGeometryEffect(id: Texts.NamespaceID.selectedTab, in: namespace)
            .transition(.opacity)
    }
    
    private var emptyRectangle: some View {
        Rectangle()
            .foregroundStyle(Color.clear)
    }
}

#Preview {
    FolderCell(folder: .lists, selected: true, namespace: Namespace().wrappedValue)
}
