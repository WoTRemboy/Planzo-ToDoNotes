//
//  CustomCalendarView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct CustomCalendarView: View {
    
    @Namespace private var calendarCellNamespace
    
    @EnvironmentObject private var coreDataManager: CoreDataViewModel
    @EnvironmentObject private var viewModel: CalendarViewModel
    
    private let columns = Array(repeating: GridItem(.flexible()),
                                count: 7)
    
    internal var body: some View {
        VStack {
            weekdayNames
            daysGrid
        }
        .padding(.horizontal)
    }
    
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
    
    private var daysGrid: some View {
        LazyVGrid(columns: columns) {
            ForEach(viewModel.days, id: \.self) { day in
                if day.monthInt != viewModel.calendarDate.monthInt {
                    Text(String())
                } else {
                    let hasTask = coreDataManager.daysWithTasks.contains(day.startOfDay)
                    CustomCalendarCell(
                        day: day.formatted(.dateTime.day()),
                        selected: viewModel.selectedDate == day.startOfDay,
                        today: Date.now.startOfDay == day.startOfDay,
                        task: hasTask,
                        namespace: calendarCellNamespace)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedDate = day
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CustomCalendarView()
        .environmentObject(CalendarViewModel())
        .environmentObject(CoreDataViewModel())
}
