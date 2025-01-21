//
//  DateFormatter.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import Foundation

extension Date {
    private static let shortWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: Texts.DateParameters.locale)
        return formatter
    }()
    
    internal var shortWeekday: String {
        return Date.shortWeekdayFormatter.string(from: self).lowercased()
    }
    
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: Texts.DateParameters.locale)
        return formatter
    }()
    
    internal var shortDate: String {
        return Date.shortDateFormatter.string(from: self).lowercased()
    }
    
    private static let longMonthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL, yyyy"
        formatter.locale = Locale(identifier: Texts.DateParameters.locale)
        return formatter
    }()
    
    internal var longMonthYear: String {
        return Date.longMonthYearFormatter.string(from: self).lowercased()
    }
    
    private static let longDayMonthWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, E"
        formatter.locale = Locale(identifier: Texts.DateParameters.locale)
        return formatter
    }()
    
    internal var longDayMonthWeekday: String {
        return Date.longDayMonthWeekdayFormatter.string(from: self).lowercased()
    }
        
    private static let shortDayMonthHourMinutesFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, HH:mm"
        formatter.locale = Locale(identifier: Texts.DateParameters.locale)
        return formatter
    }()
    
    internal var shortDayMonthHourMinutes: String {
        return Date.shortDayMonthHourMinutesFormatter.string(from: self).lowercased()
    }
}
