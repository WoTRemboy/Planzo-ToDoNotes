//
//  WeekFirstDayModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 25/08/2025.
//

enum WeekFirstDay: Codable {
    case monday
    case saturday
    case sunday
    
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
}
