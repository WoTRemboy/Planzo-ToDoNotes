//
//  CalendarTaskList.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

/// A placeholder view displayed when there are no tasks for the selected day in the Calendar screen.
struct CalendarTaskFormPlaceholder: View {
    
    // MARK: - Properties
    
    /// The date for which the placeholder is shown.
    private let date: Date
    /// Namespace for shared transitions.
    private let namespace: Namespace.ID
    
    // MARK: - Initialization
        
    /// Initializes the placeholder view with a date and animation namespace.
    ///
    /// - Parameters:
    ///   - date: The selected date.
    ///   - namespace: A namespace for shared matched transitions.
    init(date: Date, namespace: Namespace.ID) {
        self.date = date
        self.namespace = namespace
    }
    
    // MARK: - Body
    
    internal var body: some View {
        VStack(spacing: 16) {
            dateLabel
            VStack(spacing: 0) {
                emptyListImage
                emptyListLabel
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Displays the selected date with a smooth transition on change.
    private var dateLabel: some View {
        Text(date.longDayMonthWeekday)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .contentTransition(.numericText(value: date.timeIntervalSince1970))
    }
    
    /// Shows an image representing a free day (no tasks scheduled).
    private var emptyListImage: some View {
        Image.Placeholder.calendarFreeDay
            .resizable()
            .scaledToFit()
            .padding([.top, .horizontal])
    }
    
    /// Displays a text message informing the user that there are no tasks.
    private var emptyListLabel: some View {
        Text(Texts.CalendarPage.emptyList)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelPrimary)
            .padding([.top, .bottom])
    }
}

// MARK: - Preview

#Preview {
    CalendarTaskFormPlaceholder(
        date: Date.now,
        namespace: Namespace().wrappedValue)
}
