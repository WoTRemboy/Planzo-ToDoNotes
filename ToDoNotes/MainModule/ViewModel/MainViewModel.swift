//
//  MainViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    
    @Published private(set) var selectedFilter: Filter = .active
    
    internal func setFilter(to new: Filter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFilter = new
        }
    }
    
    internal func compareFilters(from filter: Filter) -> Bool {
        filter == selectedFilter
    }
}
