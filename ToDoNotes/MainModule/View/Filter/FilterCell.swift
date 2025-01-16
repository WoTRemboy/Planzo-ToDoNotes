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
    
    init(name: String, selected: Bool) {
        self.name = name
        self.selected = selected
    }
    
    internal var body: some View {
        VStack(spacing: 6) {
            nameLabel
            underline
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
            .foregroundStyle(selected ? Color.LabelColors.labelPrimary : Color.clear)
            .frame(maxWidth: .infinity)
            .frame(height: 2)
    }
}

#Preview {
    FilterCell(name: "Active", selected: true)
}
