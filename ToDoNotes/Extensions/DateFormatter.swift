//
//  DateFormatter.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import Foundation

extension Date {
    
    // MARK: - Short Weekday (EEE)
    
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
    
    // MARK: - Short Date (MMMM d)
    
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
    
    // MARK: - Long Month Year (LLLL, yyyy)
    
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
    
    // MARK: - Long Month Year Without Comma (LLLL yyyy)
    
    private static let longMonthYearWithoutCommaFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
    
    internal var longMonthYearWithoutComma: String {
        return Date.longMonthYearWithoutCommaFormatter.string(from: self).capitalized
    }
    
    // MARK: - Long Day Month Weekday (MMMM d, E)
    
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
    
    // MARK: - Short Day Month Hour Minutes (MMM d, HH:mm)
    
    static private func withTimeFormat(dayMonthTemplate: String, timeTemplate: String) -> String {
        switch TimeFormatSelector.current {
        case .system:
            return dayMonthTemplate + ", " + timeTemplate
        case .twelveHour:
            return dayMonthTemplate + ", h:mm a"
        case .twentyFourHour:
            return dayMonthTemplate + ", HH:mm"
        }
    }
    
    static private var shortDayMonthHourMinutesFormatter: DateFormatter {
        let formatter = DateFormatter()
        let locale = Locale.autoupdatingCurrent
        
        let dayMonthTemplate: String
        switch TimeLocale.locale {
        case .american:
            dayMonthTemplate = "MMM d"
        case .european, .russian:
            dayMonthTemplate = "d MMM"
        }
        
        let timeTemplate: String
        switch TimeFormatSelector.current {
        case .system:
            timeTemplate = DateFormatter.dateFormat(fromTemplate: "j:mm", options: 0, locale: locale) ?? "HH:mm"
        case .twelveHour:
            timeTemplate = "h:mm a"
        case .twentyFourHour:
            timeTemplate = "HH:mm"
        }
        formatter.dateFormat = dayMonthTemplate + ", " + timeTemplate
        formatter.locale = locale
        return formatter
    }
    
    internal var shortDayMonthHourMinutes: String {
        let dateString = Date.shortDayMonthHourMinutesFormatter.string(from: self)
        return TimeLocale.localizedDate(dateString: dateString)
    }
    
    // MARK: - Full Hour Minutes (j:mm)
    
    private static func makeFullHourMinutesFormatter(for format: TimeFormat) -> DateFormatter {
        let formatter = DateFormatter()
        let locale = Locale.autoupdatingCurrent
        switch format {
        case .system:
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "j:mm", options: 0, locale: locale)
        case .twelveHour:
            formatter.dateFormat = "h:mm a"
        case .twentyFourHour:
            formatter.dateFormat = "HH:mm"
        }
        formatter.locale = locale
        return formatter
    }
    
    private static var fullHourMinutesFormatter: DateFormatter {
        return makeFullHourMinutesFormatter(for: TimeFormatSelector.current)
    }
    
    internal var fullHourMinutes: String {
        let dateString = Date.fullHourMinutesFormatter.string(from: self)
        return dateString
    }
    
    internal static var iso8601DateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}

// MARK: - Time Locale Model

/// Defines supported locale types for date formatting.
enum TimeLocale: String {
    case american = "en_US" // American (US) locale formatting
    case european = "en_GB" // European (British) locale formatting
    case russian = "ru_RU"  // Russian locale formatting
        
    /// Returns the detected locale for the current device language settings.
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
    
    /// Modifies a given date string based on locale rules, specifically adjusting for Russian capitalization needs.
    static fileprivate func localizedDate(dateString: String) -> String {
        if Self.locale == .russian && Texts.DateParameters.locale.contains("ru") {
            return dateString.lowercased()
        } else {
            return dateString
        }
    }
}
