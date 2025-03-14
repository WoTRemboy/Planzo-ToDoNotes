//
//  CustomCalendarView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct CustomCalendarView: View {
        
    @EnvironmentObject private var viewModel: CalendarViewModel
    
    private let dates: [Date: Int]
    private let namespace: Namespace.ID
    
    private let columns = Array(repeating: GridItem(.flexible()),
                                count: 7)
    
    init(dates: [Date: Int],
         namespace: Namespace.ID) {
        self.dates = dates
        self.namespace = namespace
    }
    
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
                    .foregroundStyle(Color.LabelColors.labelGreyLight)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var daysGrid: some View {
        Group {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.days, id: \.self) { day in
                    if day.monthInt != viewModel.calendarDate.monthInt {
                        Text(String())
                    } else {
                        CustomCalendarCell(
                            day: day.formatted(.dateTime.day()),
                            selected: viewModel.selectedDate == day.startOfDay,
                            today: Date.now.startOfDay == day.startOfDay,
                            task: dates[day] != nil,
                            namespace: namespace)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                viewModel.selectedDate = day.startOfDay
                            }
                        }
                    }
                }
            }
        }
        .id(viewModel.calendarDate)
    }
}

#Preview {
    CustomCalendarView(dates: [.now: 2], namespace: Namespace().wrappedValue)
        .environmentObject(CalendarViewModel())
}
