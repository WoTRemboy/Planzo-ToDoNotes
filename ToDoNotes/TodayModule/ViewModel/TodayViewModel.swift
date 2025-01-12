//
//  TodayViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

final class TodayViewModel: ObservableObject {
    
    @Published internal var showingTaskEditView: Bool = false
    
    private(set) var todayDate: Date = Date.now
    
    internal func toggleShowingTaskEditView() {
        showingTaskEditView.toggle()
    }
}
