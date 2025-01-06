//
//  CalendarNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct CalendarNavBar: View {
    private let date: String
    private let monthYear: String
    
    init(date: String, monthYear: String) {
        self.date = date
        self.monthYear = monthYear
    }
    
    internal var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .background(.ultraThinMaterial)
            
            content
                .padding(.bottom)
            
        }
        .frame(height: 46.5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            HStack {
                titleLabel
                buttons
            }
        }
    }
    
    private var titleLabel: some View {
        HStack(spacing: 8) {
            Text(date)
                .font(.system(size: 20, weight: .regular))
            
            Text(monthYear)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
    }
    
    private var buttons: some View {
        HStack(spacing: 20) {
            // Calendar Button
            Button {
                // Action for calendar button
            } label: {
                Image.NavigationBar.calendar
            }
            
            // More options Button
            Button {
                // Action for more options button
            } label: {
                Image.NavigationBar.more
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    CalendarNavBar(date: "Сегодня", monthYear: "декабрь, 2024")
        .environmentObject(TodayViewModel())
}
