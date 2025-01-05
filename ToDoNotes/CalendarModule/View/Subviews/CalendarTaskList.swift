//
//  CalendarTaskList.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct CalendarTaskList: View {
    
    private let date: String
    
    init(date: String) {
        self.date = date
    }
    
    internal var body: some View {
        VStack(spacing: 16) {
            dateLabel
            emptyListImage
            emptyListLabel
        }
    }
    
    private var dateLabel: some View {
        Text("\(Texts.CalendarPage.today) \(date)")
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(Color.LabelColors.labelSecondary)
    }
    
    private var emptyListImage: some View {
        Image.TaskManagement.emptyList
            .resizable()
            .frame(width: 150, height: 150)
            .padding(.top, 16)
    }
    
    private var emptyListLabel: some View {
        Text(Texts.CalendarPage.emptyList)
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(Color.LabelColors.labelPrimary)
    }
}

#Preview {
    CalendarTaskList(date: "30 декабря, пн")
}
