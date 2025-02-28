//
//  CalendarNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct CalendarNavBar: View {
    @EnvironmentObject private var viewModel: CalendarViewModel

    private let date: String
    private let monthYear: String
        
    init(date: String, monthYear: String) {
        self.date = date
        self.monthYear = monthYear
    }
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                Color.BackColors.backDefault
                    .shadow(color: Color.ShadowColors.shadowDefault, radius: 15, x: 0, y: 5)
                
                VStack(spacing: 0) {
                    HStack {
                        titleLabel
                        buttons
                    }
                }
                .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    private var titleLabel: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.restoreTodayDate()
                }
            } label: {
                Text(date)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
            }
            
            Text(monthYear)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelSecondary)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
    }
    
    private var buttons: some View {
        HStack(spacing: 20) {
            // Calendar Button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleShowingCalendarSelector()
                }
            } label: {
                Image.NavigationBar.calendar
                    .resizable()
                    .frame(width: 26, height: 26)
            }
            
            // More options Button
//            Button {
                // Action for more options button
//            } label: {
//                Image.NavigationBar.more
//                    .resizable()
//                    .frame(width: 26, height: 26)
//            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    CalendarNavBar(date: "Сегодня", monthYear: "декабрь, 2024")
        .environmentObject(CalendarViewModel())
}
