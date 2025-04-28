//
//  CustomCalendarCell.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

/// A single day cell inside a custom calendar view.
struct CustomCalendarCell: View {
    
    // MARK: - Properties
    
    /// Day number as string.
    private let day: String
    /// Boolean indicating if the cell is currently selected.
    private let isSelected: Bool
    /// Boolean indicating if the cell represents today (current date).
    private let isToday: Bool
    /// Boolean indicating if there are any tasks scheduled for this date.
    private let hasTask: Bool
    /// Namespace for enabling smooth animations when switching selection.
    private let namespace: Namespace.ID
    
    // MARK: - Initialization
    
    /// Creates a new instance of a calendar day cell.
    /// - Parameters:
    ///   - day: The day number as a string.
    ///   - selected: Whether the day is currently selected.
    ///   - today: Whether the day represents the current date.
    ///   - task: Whether tasks exist for the date.
    ///   - namespace: Namespace ID for matched animations.
    init(day: String, selected: Bool,
         today: Bool, task: Bool,
         namespace: Namespace.ID) {
        self.day = day
        self.isSelected = selected
        self.isToday = today
        self.hasTask = task
        self.namespace = namespace
    }
    
    // MARK: - Body
    
    internal var body: some View {
        dayLabel
            .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
            .background(selectedBackground)
            .overlay(alignment: .top, content: taskIndicator)
            .overlay(alignment: .bottom, content: todayUnderline)
    }
    
    // MARK: - Subviews
    
    /// View displaying the day number text.
    private var dayLabel: some View {
        Text(day)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(dayColor)
    }
    
    /// View showing a small top-centered circle if a task exists for the day.
    private func taskIndicator() -> some View {
        Circle()
            .frame(width: 5, height: 5)
            .foregroundStyle(taskIndicatorColor)
            .padding(.top, 2)
            .zIndex(1)
    }
    
    /// View showing a bottom underline for today's date.
    private func todayUnderline() -> some View {
        Rectangle()
            .foregroundStyle(isToday ? Color.LabelColors.labelPrimary : Color.clear)
            .frame(maxWidth: .infinity)
            .frame(height: 2)
    }
    
    /// Background view that highlights the selected day.
    private var selectedBackground: some View {
        Group {
            if isSelected && !isToday {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                    .transition(.blurReplace)
                    .animation(.easeInOut(duration: 0.1), value: isSelected)
            }
        }
    }
    
    // MARK: - Computed Colors
    
    /// Color for the day number text based on selection and today's status.
    private var dayColor: Color {
        if isToday {
            return Color.LabelColors.labelPrimary
        } else if isSelected {
            return Color.LabelColors.labelReversed
        } else {
            return Color.LabelColors.labelSecondary
        }
    }
    
    /// Color for the small task indicator based on task presence and state.
    private var taskIndicatorColor: Color {
        if isToday && hasTask {
            return Color.LabelColors.labelPrimary
        } else if isSelected && hasTask {
            return Color.LabelColors.labelReversed
        } else if hasTask {
            return Color.LabelColors.labelSecondary
        } else {
            return Color.clear
        }
    }
}

// MARK: - Preview

#Preview {
    CustomCalendarCell(day: "5",
                       selected: true,
                       today: false,
                       task: true,
                       namespace: Namespace().wrappedValue)
}
