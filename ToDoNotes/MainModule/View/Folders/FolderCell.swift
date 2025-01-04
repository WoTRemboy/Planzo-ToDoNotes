//
//  FolderCell.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct FolderCell: View {
    
    private let name: String
    private let selected: Bool
    
    init(name: String, selected: Bool) {
        self.name = name
        self.selected = selected
    }
    
    internal var body: some View {
        nameLabel
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .overlay(
                overlayRectangle
            )
    }
    
    private var nameLabel: some View {
        Text(name)
            .font(.system(size: 16, weight: .light))
            .foregroundStyle(selected ? Color.LabelColors.labelPrimary : Color.LabelColors.labelSecondary)
    }
    
    private var overlayRectangle: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(selected ? Color.LabelColors.labelPrimary : Color.LabelColors.labelSecondary,
                    lineWidth: 1)
    }
}

#Preview {
    FolderCell(name: "Пароли", selected: true)
}
