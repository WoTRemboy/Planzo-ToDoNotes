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
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
    
    internal var shortWeekday: String {
        let dateString = Date.shortWeekdayFormatter.string(from: self)
        return TimeLocale.localizedDate(dateString: dateString)
    }
    
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        switch TimeLocale.locale {
        case .american:
            formatter.dateFormat = "MMMM d"
        case .european, .russian:
            formatter.dateFormat = "d MMMM"
        }
        
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
    
    internal var shortDate: String {
        let dateString = Date.shortDateFormatter.string(from: self)
        return TimeLocale.localizedDate(dateString: dateString)
    }
    
    private static let longMonthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL, yyyy"
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
    
    internal var longMonthYear: String {
        let dateString = Date.longMonthYearFormatter.string(from: self)
        return TimeLocale.localizedDate(dateString: dateString)
    }
    
    private static let longMonthYearWithoutCommaFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
    
    internal var longMonthYearWithoutComma: String {
        return Date.longMonthYearWithoutCommaFormatter.string(from: self).capitalized
    }
    
    private static let longDayMonthWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        switch TimeLocale.locale {
        case .american:
            formatter.dateFormat = "MMMM d, E"
        case .european, .russian:
            formatter.dateFormat = "d MMMM, E"
        }
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
    
    internal var longDayMonthWeekday: String {
        let dateString = Date.longDayMonthWeekdayFormatter.string(from: self)
        return TimeLocale.localizedDate(dateString: dateString)
    }
        
    private static let shortDayMonthHourMinutesFormatter: DateFormatter = {
        let formatter = DateFormatter()
        switch TimeLocale.locale {
        case .american:
            formatter.dateFormat = "MMM d, HH:mm"
        case .european, .russian:
            formatter.dateFormat = "d MMM, HH:mm"
        }
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
    
    internal var shortDayMonthHourMinutes: String {
        let dateString = Date.shortDayMonthHourMinutesFormatter.string(from: self)
        return TimeLocale.localizedDate(dateString: dateString)
    }
    
    private static let fullHourMinutesFormatter: DateFormatter = {
        let formatter = DateFormatter()
        let locale = Locale.autoupdatingCurrent
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "j:mm", options: 0, locale: locale)
        return formatter
    }()
    
    internal var fullHourMinutes: String {
        let dateString = Date.fullHourMinutesFormatter.string(from: self)
        return dateString
    }
}


enum TimeLocale: String {
    case american = "en_US"
    case european = "en_GB"
    case russian = "ru_RU"
    
    static fileprivate var locale: TimeLocale {
        let id = Locale.autoupdatingCurrent.identifier
        if id.contains("ru") {
            return .russian
        } else if id.contains("en_US") {
            return .american
        } else {
            return .european
        }
    }
    
    static fileprivate func localizedDate(dateString: String) -> String {
        if Self.locale == .russian && Texts.DateParameters.locale.contains("ru") {
            return dateString.lowercased()
        } else {
            return dateString
        }
    }
}
