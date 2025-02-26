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
        nameLabel
    }
    
    private var nameLabel: some View {
        Text(name)
            .font(.system(size: 22, weight: selected ? .bold : .medium))
            .foregroundStyle(selected ? Color.LabelColors.labelPrimary : Color.LabelColors.labelSecondary)
            .frame(maxWidth: .infinity)
            .transition(.scale)
    }
}

#Preview {
    FilterCell(name: "Active", selected: true)
}
