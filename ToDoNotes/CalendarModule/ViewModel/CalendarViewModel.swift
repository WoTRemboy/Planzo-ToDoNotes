//
//  CalendarViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

final class CalendarViewModel: ObservableObject {
    
    @AppStorage(Texts.UserDefaults.addTaskButtonGlow) var addTaskButtonGlow: Bool = false
    
    @Published internal var showingTaskCreateView: Bool = false
    @Published internal var selectedTask: TaskEntity? = nil
    @Published internal var selectedDate: Date = .now
    @Published internal var taskManagementHeight: CGFloat = 15
    
    internal let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    private(set) var todayDate: Date = Date.now
    private(set) var days: [Date] = []
    
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    init() {
        updateDays()
    }
    
    internal func toggleShowingTaskCreateView() {
        showingTaskCreateView.toggle()
    }
    
    internal func toggleShowingTaskEditView() {
        selectedTask = nil
    }
    
    internal func updateDays() {
        days = todayDate.calendarDisplayDays
    }
}
