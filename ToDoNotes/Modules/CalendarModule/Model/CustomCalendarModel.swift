//
//  CustomCalendarModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import Foundation

/// Extension for `Date` providing utilities for working with custom calendar displays,
/// like getting weekdays, month names, and calculating calendar layouts.
extension Date {
    
    static var firstDayOfWeek: Int {
        get {
            UserDefaults.standard.integer(forKey: Texts.UserDefaults.firstDayOfWeek)
                .nonZeroOr(Calendar.current.firstWeekday)
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: Texts.UserDefaults.firstDayOfWeek
            )
        }
    }
    
    // MARK: - Static Computed Properties

    /// Returns an array of capitalized short names of weekdays,
    /// adjusted to start from the user-selected first weekday stored in UserDefaults.
    static internal var capitalizedFirstLettersOfWeekdays: [String] {
        var weekdays = Calendar.current.shortWeekdaySymbols
        
        // Adjust the weekdays array to match the first day of the week.
        if Self.firstDayOfWeek > 1 {
            for _ in 1..<Self.firstDayOfWeek {
                if let first = weekdays.first {
                    weekdays.append(first)
                    weekdays.removeFirst()
                }
            }
        }
        return weekdays.map { $0.uppercased() }
    }
    
    /// Returns full localized names of all months.
    static internal var fullMonthNames: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        
        return (1...12).compactMap { month in
            formatter.setLocalizedDateFormatFromTemplate("MMMM")
            let date = Calendar.current.date(from: DateComponents(year: 2000,
                                                                  month: month,
                                                                  day: 1))
            return date.map { formatter.string(from: $0) }
        }
    }
    
    /// Returns today's day of month as an Int (1–31).
    static var todayDay: Int {
        Calendar.current.component(.day, from: .now)
    }
    
    // MARK: - Instance Properties
    
    /// Returns the month component (1–12) of the date.
    internal var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }
    
    /// Returns the date at the start of the day.
    internal var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
        
    /// Returns the start of the month for the date.
    private var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)?.start ?? .now
    }
    
    /// Returns the end of the month for the date.
    private var endOfMonth: Date {
        let lastDay = Calendar.current.dateInterval(of: .month, for: self)?.end ?? .now
        return Calendar.current.date(byAdding: .day, value: -1, to: lastDay) ?? .now
    }
    
    /// Returns the number of days in the month.
    private var numberOfDaysInMonth: Int {
        Calendar.current.component(.day, from: endOfMonth)
    }
    
    /// Returns the first day to display before the start of the month in a calendar grid.
    /// This ensures that the calendar layout starts at the beginning of the user-selected week.
    private var firstWeekDayBeforeStart: Date {
        let startOfMonthWeekday = Calendar.current.component(.weekday, from: startOfMonth)
        var numberFromPreviousMonth = startOfMonthWeekday - Self.firstDayOfWeek
        
        if numberFromPreviousMonth < 0 {
            numberFromPreviousMonth += 7
        }
        return Calendar.current.date(byAdding: .day, value: -numberFromPreviousMonth, to: startOfMonth) ?? .now
    }
    
    // MARK: - Display Days Computed Property

    /// Returns an array of `Date` representing all days to display in a month view,
    /// including days from the previous month necessary to complete the first week,
    /// taking into account the user-selected first day of the week.
    internal var calendarDisplayDays: [Date] {
       var days: [Date] = []
        
        // Fill in days from previous month up to the start of the month
       var currentDay = firstWeekDayBeforeStart
       while currentDay < startOfMonth {
           days.append(currentDay)
           currentDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDay) ?? .now
       }
        
        // Fill in days of the current month
       for dayOffset in 0..<numberOfDaysInMonth {
           let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfMonth) ?? .now
           days.append(newDay)
       }
       return days
    }
}

extension Int {
    /// Returns the fallback if the integer is zero, otherwise returns self.
    fileprivate func nonZeroOr(_ fallback: Int) -> Int {
        self == 0 ? fallback : self
    }
}
