//
//  TaskCustomCalendar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/28/25.
//

import SwiftUI

struct TaskCustomCalendar: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    
    init(viewModel: TaskManagementViewModel) {
        self.viewModel = viewModel
    }
    
    private let columns = Array(repeating: GridItem(.flexible()),
                                count: 7)
    
    internal var body: some View {
        VStack {
            monthSelector
            weekdayNames
            daysGrid
        }
        .onChange(of: viewModel.days) { _ in
            viewModel.updateDays()
        }
        .padding(.horizontal, 16)
    }
    
    private var monthSelector: some View {
        HStack {
            Button {
                // Action for month forward
            } label: {
                Image.TaskManagement.DateSelector.monthBackward
            }
            
            Spacer()
            Text("Январь 2025")
                .font(.system(size: 17, weight: .medium))
            
            Spacer()
            Button {
                // Action for month backward
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
        LazyVGrid(columns: columns) {
            ForEach(viewModel.days, id: \.self) { day in
                if day.monthInt != viewModel.todayDate.monthInt {
                    Text(String())
                } else {
                    CustomCalendarCell(
                        day: day.formatted(.dateTime.day()),
                        selected: viewModel.selectedDay == day.startOfDay,
                        today: Date.now.startOfDay == day.startOfDay,
                        task: false)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedDay = day.startOfDay
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TaskCustomCalendar(viewModel: TaskManagementViewModel())
}
