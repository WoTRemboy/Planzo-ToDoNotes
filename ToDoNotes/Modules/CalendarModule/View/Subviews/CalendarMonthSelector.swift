//
//  CalendarMonthSelector.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/7/25.
//

import SwiftUI

/// A bottom sheet view that allows users to select a month and year using a `DatePicker`.
struct CalendarMonthSelector: View {
    
    /// ViewModel responsible for the calendar logic and state.
    @EnvironmentObject private var viewModel: CalendarViewModel
    
    // MARK: - Body
        
    internal var body: some View {
        VStack(spacing: 0) {
            content
            cancelButton
        }
        .frame(width: 350)
        .background(Color.BackColors.backSecondary)
        .cornerRadius(12)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Shape Picker
    
    /// DatePicker allowing user to choose month and year.
    private var content: some View {
        HStack {
            DatePicker(selection: $viewModel.calendarDate.animation(.easeInOut(duration: 0.2)),
                       displayedComponents: .date) {
                // Hides label text
                EmptyView()
            }
            .labelsHidden()
            .datePickerStyle(.wheel)
        }
    }
    
    // MARK: - Cancel Button
    
    /// A button that closes the month selector sheet.
    private var cancelButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleShowingCalendarSelector()
            }
        } label: {
            ZStack {
                // Primary color for button background
                Color.LabelColors.labelPrimary
                
                Text(Texts.CalendarPage.close)
                    .font(.system(size: 17, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.LabelColors.labelReversed)
            }
            .clipShape(.rect(cornerRadius: 10))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding([.horizontal, .bottom], 6)
    }
}

// MARK: - Preview

#Preview {
    CalendarMonthSelector()
        .environmentObject(CalendarViewModel())
}
