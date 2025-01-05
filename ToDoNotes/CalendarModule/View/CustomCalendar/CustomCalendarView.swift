//
//  CustomCalendarView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct CustomCalendarView: View {
    
    @EnvironmentObject private var viewModel: CalendarViewModel
    
    private let columns = Array(repeating: GridItem(.flexible()),
                                count: 7)
    
    internal var body: some View {
        VStack {
            weekdayNames
            daysGrid
        }
        .onChange(of: viewModel.days) { _ in
            viewModel.updateDays()
        }
        .padding(.horizontal)
    }
    
    private var weekdayNames: some View {
        HStack {
            ForEach(viewModel.daysOfWeek.indices, id: \.self) { index in
                Text(viewModel.daysOfWeek[index])
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Color.LabelColors.labelTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var daysGrid: some View {
        LazyVGrid(columns: columns) {
            ForEach(viewModel.days, id: \.self) { day in
                if day.monthInt != viewModel.todayDate.monthInt {
                    Text(String())
                } else {
                    CustomCalendarCell(
                        day: day.formatted(.dateTime.day()),
                        today: Date.now.startOfDay == day.startOfDay)
                }
            }
        }
    }
}

#Preview {
    CustomCalendarView()
        .environmentObject(CalendarViewModel())
}
