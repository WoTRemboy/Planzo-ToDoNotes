//
//  TaskCustomCalendar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/28/25.
//

import SwiftUI

struct TaskCustomCalendar: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    private let animation: Namespace.ID
    
    init(viewModel: TaskManagementViewModel,
         namespace: Namespace.ID) {
        self.viewModel = viewModel
        self.animation = namespace
    }
    
    private let columns = Array(repeating: GridItem(.flexible()),
                                count: 7)
    
    internal var body: some View {
        VStack {
            monthSelector
            weekdayNames
            daysGrid
        }
        .padding(.horizontal, 16)
    }
    
    private var monthSelector: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.calendarMonthMove(for: .backward)
                }
            } label: {
                Image.TaskManagement.DateSelector.monthBackward
            }
            
            Spacer()
            Text(viewModel.calendarDate.longMonthYearWithoutComma)
                .font(.system(size: 17, weight: .medium))
                .contentTransition(
                    .numericText(countsDown: viewModel.calendarSwapDirection == .backward))
            
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.calendarMonthMove(for: .forward)
                }
            } label: {
                Image.TaskManagement.DateSelector.monthForward
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
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
        Group {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.days, id: \.self) { day in
                    if day.monthInt != viewModel.calendarDate.monthInt {
                        Text(String())
                    } else {
                        CustomCalendarCell(
                            day: day.formatted(.dateTime.day()),
                            selected: viewModel.selectedDay == day.startOfDay,
                            today: Date.now.startOfDay == day.startOfDay,
                            task: false,
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

#Preview {
    TaskCustomCalendar(viewModel: TaskManagementViewModel(),
                       namespace: Namespace().wrappedValue)
}
