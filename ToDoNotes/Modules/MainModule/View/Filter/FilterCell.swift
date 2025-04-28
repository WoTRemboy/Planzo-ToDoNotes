//
//  FilterCell.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

/// A single filter button displayed in the `FilterScrollView`.
struct FilterCell: View {
    
    // MARK: - Properties
        
    /// Indicates whether this filter is currently selected.
    private let selected: Bool
    /// The filter type this cell represents.
    private let filter: Filter
    
    // MARK: - Initialization
    
    init(filter: Filter, selected: Bool) {
        self.filter = filter
        self.selected = selected
    }
    
    // MARK: - Body
    
    internal var body: some View {
        nameLabel
            .foregroundStyle(selected ? Color.LabelColors.labelPrimary : Color.LabelColors.Special.labelFilterUnselected)
            .frame(maxWidth: .infinity)
    }
    
    // MARK: - Name or Icon
    
    /// Displays either the filter's name or a custom icon if it's the deleted filter.
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

// MARK: - Preview

#Preview {
    FilterCell(filter: .deleted, selected: true)
}
