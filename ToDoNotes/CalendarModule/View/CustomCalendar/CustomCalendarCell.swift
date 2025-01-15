//
//  CustomCalendarCell.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct CustomCalendarCell: View {
    
    private let day: String
    private let today: Bool
    
    init(day: String, today: Bool) {
        self.day = day
        self.today = today
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
            .foregroundStyle(Color.clear)
        
    }
    
    private var dayNumber: some View {
        Text(day)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(today ? Color.LabelColors.labelPrimary : Color.LabelColors.labelSecondary)
    }
    
    private var underline: some View {
        Rectangle()
            .foregroundStyle(today ? Color.LabelColors.labelPrimary : Color.clear)
            .frame(maxWidth: .infinity)
            .frame(height: 2)
    }
}

#Preview {
    CustomCalendarCell(day: "5", today: true)
}
