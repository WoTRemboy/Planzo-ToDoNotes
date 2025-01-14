//
//  CalendarViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

final class CalendarViewModel: ObservableObject {
    
    internal let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    private(set) var todayDate: Date = Date.now
    private(set) var days: [Date] = []
    
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    init() {
        updateDays()
    }
    
    internal func updateDays() {
        days = todayDate.calendarDisplayDays
    }
}
