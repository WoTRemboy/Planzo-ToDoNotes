//
//  FilterCell.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct FilterCell: View {
        
    private let selected: Bool
    private let filter: Filter
    
    init(filter: Filter, selected: Bool) {
        self.filter = filter
        self.selected = selected
    }
    
    internal var body: some View {
        nameLabel
            .foregroundStyle(selected ? Color.LabelColors.labelPrimary : Color.LabelColors.Special.labelFilterUnselected)
            .frame(maxWidth: .infinity)
    }
    
    private var nameLabel: some View {
        Group {
            if filter != .deleted {
                Text(filter.name)
                    .font(.system(size: 22, weight: selected ? .bold : .medium))
            } else {
                Image.NavigationBar.MainTodayPages.deletedFilter
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 22, height: 22)
            }
        }
    }
}

#Preview {
    FilterCell(filter: .deleted, selected: true)
}
