//
//  WeekFirstDayModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 25/08/2025.
//

enum WeekFirstDay: Int, Codable {
    case sunday = 1
    case monday = 2
    case saturday = 7
    
    static let allCases: [WeekFirstDay] = [.monday, .saturday, .sunday]
    
    internal var name: String {
        switch self {
        case .monday:
            Texts.Settings.WeekFirstDay.monday
        case .saturday:
            Texts.Settings.WeekFirstDay.saturday
        case .sunday:
            Texts.Settings.WeekFirstDay.sunday
        }
    }
    
    static func setupValue(for value: Int) -> WeekFirstDay {
        WeekFirstDay(rawValue: value) ?? .monday
    }
}
