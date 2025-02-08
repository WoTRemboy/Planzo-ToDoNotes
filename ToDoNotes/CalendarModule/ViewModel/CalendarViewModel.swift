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
    @Published internal var showingCalendarSelector: Bool = false
    
    @Published internal var selectedTask: TaskEntity? = nil
    @Published internal var selectedDate: Date = .now.startOfDay
    @Published internal var taskManagementHeight: CGFloat = 15
    
    @Published internal var calendarDate: Date = Date.now {
        didSet {
            updateDays()
            selectDay()
        }
    }
    
    private(set) var days: [Date] = []
    internal let daysOfWeek: [String] = Date.capitalizedFirstLettersOfWeekdays
    
    init() {
        updateDays()
    }
    
    internal func toggleShowingTaskCreateView() {
        showingTaskCreateView.toggle()
    }
    
    internal func toggleShowingCalendarSelector() {
        showingCalendarSelector.toggle()
    }
    
    internal func toggleShowingTaskEditView() {
        selectedTask = nil
    }
    
    private func updateDays() {
        days = calendarDate.calendarDisplayDays
    }
    
    private func selectDay() {
        selectedDate = Calendar.current.startOfDay(for: calendarDate)
    }
    
    internal func restoreTodayDate() {
        guard selectedDate != .now.startOfDay else { return }
        calendarDate = .now.startOfDay
    }
}
