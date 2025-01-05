//
//  CalendarView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject private var viewModel: CalendarViewModel
    
    internal var body: some View {
        ZStack {
            content
            plusButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            CalendarNavBar(date: Texts.CalendarPage.today,
                           monthYear: viewModel.todayDate.longMonthYear)
        }
    }
    
    private var content: some View {
        VStack {
            CustomCalendarView()
            separator
            CalendarTaskList(date: viewModel.todayDate.longDayMonthWeekday)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 60)
    }
    
    private var separator: some View {
        Divider()
            .background(Color.LabelColors.labelTertiary)
            .frame(height: 0.36)
            .padding()
    }
    
    private var plusButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    // Action for plus button
                } label: {
                    Image.TaskManagement.plus
                        .resizable()
                        .scaledToFit()
                        .frame(width: 58, height: 58)
                }
                .padding()
            }
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(CalendarViewModel())
}
