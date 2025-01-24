//
//  CustomCalendarCell.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct CustomCalendarCell: View {
    
    private let day: String
    private let selected: Bool
    private let today: Bool
    private let task: Bool
    
    init(day: String, selected: Bool,
         today: Bool, task: Bool) {
        self.day = day
        self.selected = selected
        self.today = today
        self.task = task
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            taskMark
            Spacer()
            dayNumber
            Spacer()
            underline
        }
        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
    }
    
    private var taskMark: some View {
        Circle()
            .frame(width: 5, height: 5)
            .foregroundStyle(task ?
                             Color.LabelColors.labelSecondary:
                                Color.clear)
    }
    
    private var dayNumber: some View {
        Text(day)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(today ? Color.LabelColors.labelPrimary : Color.LabelColors.labelSecondary)
            .background {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundStyle((selected && !today) ?
                                     Color.LabelColors.labelDisable:
                                        Color.clear)
            }
    }
    
    private var underline: some View {
        Rectangle()
            .foregroundStyle(today ? Color.LabelColors.labelPrimary : Color.clear)
            .frame(maxWidth: .infinity)
            .frame(height: 2)
    }
}

#Preview {
    CustomCalendarCell(day: "5",
                       selected: true,
                       today: true,
                       task: true)
}
