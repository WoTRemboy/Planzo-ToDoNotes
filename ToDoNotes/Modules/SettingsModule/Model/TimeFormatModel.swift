//
//  TimeFormatModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 25/08/2025.
//

enum TimeFormat: Codable {
    case twelveHour
    case twentyFourHour
    case system
    
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
