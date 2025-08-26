//
//  WeekFirstDayModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 25/08/2025.
//

enum WeekFirstDay: Int, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    static let allCases: [WeekFirstDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    internal var name: String {
        switch self {
        case .monday:
            Texts.Settings.WeekFirstDay.monday
        case .tuesday:
            Texts.Settings.WeekFirstDay.tuesday
        case .wednesday:
            Texts.Settings.WeekFirstDay.wednesday
        case .thursday:
            Texts.Settings.WeekFirstDay.thursday
        case .friday:
            Texts.Settings.WeekFirstDay.friday
        case .saturday:
            Texts.Settings.WeekFirstDay.saturday
        case .sunday:
            Texts.Settings.WeekFirstDay.sunday
        }
    }
    
    static func setupValue(for raw: Int) -> WeekFirstDay {
        WeekFirstDay(rawValue: raw) ?? .monday
    }
}
