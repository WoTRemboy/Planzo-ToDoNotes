//
//  TaskCustomCalendar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/28/25.
//

import SwiftUI

/// A custom calendar view used for selecting specific dates within task management.
struct TaskCustomCalendar: View {
    
    // MARK: - Properties
    
    /// ViewModel handling calendar data and selected date.
    @ObservedObject private var viewModel: TaskManagementViewModel
    /// Animation namespace for matched transitions.
    private let animation: Namespace.ID
    
    /// Calendar grid with 7 columns (for 7 days of the week).
    private let columns = Array(repeating: GridItem(.flexible()),
                                count: 7)
    
    // MARK: - Initialization
    
    /// Initializes the custom calendar.
    /// - Parameters:
    ///   - viewModel: The view model for managing selected days and month movements.
    ///   - namespace: The animation namespace for smooth transitions.
    init(viewModel: TaskManagementViewModel,
         namespace: Namespace.ID) {
        self.viewModel = viewModel
        self.animation = namespace
    }
    
    // MARK: - Body
    
    /// Main body rendering the full calendar layout.
    internal var body: some View {
        VStack {
            monthSelector
            weekdayNames
            daysGrid
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Month Selector
    
    /// A month selector with buttons to navigate forward and backward.
    private var monthSelector: some View {
        HStack {
            backwardButton
            
            Spacer()
            Text(viewModel.calendarDate.longMonthYearWithoutComma)
                .font(.system(size: 17, weight: .medium))
                .contentTransition(
                    .numericText(value: viewModel.calendarDate.timeIntervalSince1970))
            
            Spacer()
            forwardButton
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        .padding(.horizontal, 6)
    }
    
    /// Button to navigate backward.
    private var backwardButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.calendarMonthMove(for: .backward)
            }
        } label: {
            Image.TaskManagement.DateSelector.monthBackward
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    /// Button to navigate forward.
    private var forwardButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.calendarMonthMove(for: .forward)
            }
        } label: {
            Image.TaskManagement.DateSelector.monthForward
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    // MARK: - Calendar Subviews
    
    /// Displays the names of the days of the week.
    private var weekdayNames: some View {
        HStack {
            ForEach(viewModel.daysOfWeek.indices, id: \.self) { index in
                Text(viewModel.daysOfWeek[index])
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    /// Displays a grid of days for the current month, with selectable dates.
    private var daysGrid: some View {
        Group {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.days, id: \.self) { day in
                    if day.monthInt != viewModel.calendarDate.monthInt {
                        // Empty slot for padding from previous/next month
                        Text(String())
                    } else {
                        CustomCalendarCell(
                            day: day.formatted(.dateTime.day()),
                            selected: viewModel.selectedDay == day.startOfDay,
                            today: Date.now.startOfDay == day.startOfDay,
                            task: false, // No task marking needed in this context
                            namespace: animation)
                        
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                viewModel.selectedDay = day.startOfDay
                            }
                        }
                    }
                }
            }
        }
        .id(viewModel.calendarDate)
    }
}

// MARK: - Preview

#Preview {
    TaskCustomCalendar(viewModel: TaskManagementViewModel(),
                       namespace: Namespace().wrappedValue)
}
