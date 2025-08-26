//
//  TimeFormatModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 25/08/2025.
//

import Foundation

enum TimeFormat: String, Codable {
    case twelveHour = "Twelve Hour"
    case twentyFourHour = "Twenty Four Hour"
    case system = "System"
    
    static let allCases: [TimeFormat] = [.twelveHour, .twentyFourHour, .system]
    
    internal var name: String {
        switch self {
        case .twelveHour:
            return Texts.Settings.TimeFormat.twelveHour
        case .twentyFourHour:
            return Texts.Settings.TimeFormat.twentyFourHour
        case .system:
            return Texts.Settings.TimeFormat.system
        }
    }
}

enum TimeFormatSelector {
    static var current: TimeFormat {
        get {
            if let raw = UserDefaults.standard.string(
                forKey: Texts.UserDefaults.timeFormat
            ),
               let format = TimeFormat(rawValue: raw) {
                return format
            } else {
                return .system
            }
        }
        set {
            UserDefaults.standard.set(
                newValue.rawValue,
                forKey: Texts.UserDefaults.timeFormat
            )
        }
    }
}
