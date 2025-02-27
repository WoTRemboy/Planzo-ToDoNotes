//
//  CalendarTaskList.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct CalendarTaskFormPlaceholder: View {
    
    private let date: String
    private let namespace: Namespace.ID
    
    init(date: String, namespace: Namespace.ID) {
        self.date = date
        self.namespace = namespace
    }
    
    internal var body: some View {
        VStack(spacing: 16) {
            dateLabel
            VStack(spacing: 0) {
                emptyListImage
                emptyListLabel
            }
        }
    }
    
    private var dateLabel: some View {
        Text(date)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .contentTransition(.numericText())
            .matchedGeometryEffect(
                id: Texts.NamespaceID.selectedCalendarDate,
                in: namespace)
    }
    
    private var emptyListImage: some View {
        Image.TaskManagement.emptyList
            .resizable()
            .frame(width: 150, height: 150)
            .padding(.top, 16)
    }
    
    private var emptyListLabel: some View {
        Text(Texts.CalendarPage.emptyList)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelPrimary)
    }
}

#Preview {
    CalendarTaskFormPlaceholder(
        date: "30 декабря, пн",
        namespace: Namespace().wrappedValue)
}
