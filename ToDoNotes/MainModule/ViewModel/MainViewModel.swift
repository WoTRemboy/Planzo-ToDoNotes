//
//  MainViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    
    @Published private(set) var selectedFilter: Filter = .active
    @Published internal var selectedFolder: Folder = .all
    
    internal func setFilter(to new: Filter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFilter = new
        }
    }
    
    internal func compareFilters(with filter: Filter) -> Bool {
        filter == selectedFilter
    }
    
    internal func setFolder(to new: Folder) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFolder = new
        }
    }
    
    internal func compareFolders(with folder: Folder) -> Bool {
        folder == selectedFolder
    }
}
