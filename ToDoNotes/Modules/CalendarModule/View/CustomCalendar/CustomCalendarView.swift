//
//  CustomCalendarView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

/// A custom calendar grid displaying the current month, selectable days, and indicators for days with tasks.
struct CustomCalendarView: View {
    
    // MARK: - Properties
        
    @EnvironmentObject private var viewModel: CalendarViewModel
    
    /// Dictionary containing dates and the number of tasks on each date.
    private let datesWithTasks: [Date: Int]
    /// Namespace for transition animations between views.
    private let namespace: Namespace.ID
    
    /// Grid layout with 7 flexible columns (for 7 days of the week).
    private let columns = Array(repeating: GridItem(.flexible()),
                                count: 7)
    
    // MARK: Initialization
    
    /// Initializes a new CustomCalendarView.
    /// - Parameters:
    ///   - dates: Dates with the number of associated tasks.
    ///   - namespace: Namespace for matched geometry effects.
    init(dates: [Date: Int],
         namespace: Namespace.ID) {
        self.datesWithTasks = dates
        self.namespace = namespace
    }
    
    // MARK: - Body
    
    internal var body: some View {
        VStack {
            weekdayNames
            daysGrid
        }
        .padding(.horizontal)
    }
    
    // MARK: - Weekday Names
    
    /// Displays the names of the weekdays as headers.
    private var weekdayNames: some View {
        HStack {
            ForEach(viewModel.daysOfWeek.indices, id: \.self) { index in
                Text(viewModel.daysOfWeek[index])
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelGreyLight)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Calendar Grid
    
    /// Displays the calendar days in a grid, with highlighting for selected, today, and days with tasks.
    private var daysGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.days, id: \.self) { day in
                dayCell(for: day)
            }
        }
    }
    
    /// Returns the view for a single day cell.
    private func dayCell(for day: Date) -> some View {
        Group {
            if day.monthInt != viewModel.calendarDate.monthInt {
                // Empty cell for days outside the current month
                Text(String())
                    .frame(height: 36)
            } else {
                CustomCalendarCell(
                    day: day.formatted(.dateTime.day()),
                    selected: viewModel.selectedDate == day.startOfDay,
                    today: Date.now.startOfDay == day.startOfDay,
                    task: datesWithTasks[day] != nil,
                    namespace: namespace
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        viewModel.selectedDate = day.startOfDay
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CustomCalendarView(dates: [.now: 2], namespace: Namespace().wrappedValue)
        .environmentObject(CalendarViewModel())
}
