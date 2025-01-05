//
//  CustomCalendarModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import Foundation

extension Date {
    
    // MARK: - Static Properties
    
    static private var firstDayOfWeek = Calendar.current.firstWeekday
    
    // MARK: - Static Computed Properties

    static internal var capitalizedFirstLettersOfWeekdays: [String] {
        let calendar = Calendar.current
        
        var weekdays = calendar.shortWeekdaySymbols
        if firstDayOfWeek > 1 {
            for _ in 1..<firstDayOfWeek {
                if let first = weekdays.first {
                    weekdays.append(first)
                    weekdays.removeFirst()
                }
            }
        }
        return weekdays.map { $0.uppercased() }
    }
    
    static var fullMonthNames: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Texts.DateParameters.locale)
        
        return (1...12).compactMap { month in
            formatter.setLocalizedDateFormatFromTemplate("MMMM")
            let date = Calendar.current.date(from: DateComponents(year: 2000,
                                                                  month: month,
                                                                  day: 1))
            return date.map { formatter.string(from: $0) }
        }
    }
    
    // MARK: - Instance Properties
    
    internal var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }
    
    internal var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
        
    private var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)?.start ?? .now
    }
    
    private var endOfMonth: Date {
        let lastDay = Calendar.current.dateInterval(of: .month, for: self)?.end ?? .now
        return Calendar.current.date(byAdding: .day, value: -1, to: lastDay) ?? .now
    }
    
    private var numberOfDaysInMonth: Int {
        Calendar.current.component(.day, from: endOfMonth)
    }
    
    private var firstWeekDayBeforeStart: Date {
        let startOfMonthWeekday = Calendar.current.component(.weekday, from: startOfMonth)
        var numberFromPreviousMonth = startOfMonthWeekday - Self.firstDayOfWeek
        if numberFromPreviousMonth < 0 {
            numberFromPreviousMonth += 7
        }
        return Calendar.current.date(byAdding: .day, value: -numberFromPreviousMonth, to: startOfMonth) ?? .now
    }
    
    // MARK: - Display Days Computed Property

    internal var calendarDisplayDays: [Date] {
       var days: [Date] = []
        
       let firstDisplayDay = firstWeekDayBeforeStart
       var day = firstDisplayDay
       while day < startOfMonth {
           days.append(day)
           day = Calendar.current.date(byAdding: .day, value: 1, to: day) ?? .now
       }
        
       for dayOffset in 0..<numberOfDaysInMonth {
           let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfMonth) ?? .now
           days.append(newDay)
       }
       return days
    }
}
