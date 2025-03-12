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
    private let namespace: Namespace.ID
    
    init(day: String, selected: Bool,
         today: Bool, task: Bool,
         namespace: Namespace.ID) {
        self.day = day
        self.selected = selected
        self.today = today
        self.task = task
        self.namespace = namespace
    }
    
    internal var body: some View {
        dayNumber
            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
            .overlay(alignment: .top) {
                taskMark
            }
            .overlay(alignment: .bottom) {
                underline
            }
    }
    
    private var taskMark: some View {
        let color: Color
        if today && task {
            color = Color.LabelColors.labelPrimary
        } else if selected && task {
            color = Color.LabelColors.labelReversed
        } else if task {
            color = Color.LabelColors.labelSecondary
        } else {
            color = Color.clear
        }
        
        return Circle()
            .frame(width: 5, height: 5)
            .foregroundStyle(color)
            .padding(.top, 2)
            .zIndex(1)
    }
    
    private var dayNumber: some View {
        let color: Color
        if today {
            color = Color.LabelColors.labelPrimary
        } else if selected {
            color = Color.LabelColors.labelReversed
        } else {
            color = Color.LabelColors.labelSecondary
        }
        
        return Text(day)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(color)
        
            .background {
                if selected && !today {
                    selectedBackground
                }
            }
    }
    
    private var selectedBackground: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 44, height: 44)
            .foregroundStyle(Color.LabelColors.labelPrimary)
            .transition(.blurReplace)
//            .matchedGeometryEffect(
//                id: Texts.NamespaceID.selectedCalendarCell,
//                in: namespace)
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
                       today: false,
                       task: true,
                       namespace: Namespace().wrappedValue)
}
