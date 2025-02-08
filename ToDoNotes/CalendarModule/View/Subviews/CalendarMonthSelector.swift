//
//  CalendarMonthSelector.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/7/25.
//

import SwiftUI

struct CalendarMonthSelector: View {
    
    @EnvironmentObject private var viewModel: CalendarViewModel
        
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
    
    /// Shows the label & progress view.
    private var content: some View {
        HStack {
            Spacer()
            DatePicker(selection: $viewModel.calendarDate.animation(.easeInOut(duration: 0.2)),
                       displayedComponents: .date) {
                EmptyView()
            }
            .labelsHidden()
            .datePickerStyle(.wheel)
            Spacer()
        }
    }
    
    // MARK: - Cancel Button
    
    /// A button that toggles the visibility of the overlay.
    private var cancelButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.toggleShowingCalendarSelector()
            }
        } label: {
            Text(Texts.CalendarPage.accept)
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        
        .foregroundColor(Color.blue)
        .buttonStyle(.bordered)
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    CalendarMonthSelector()
        .environmentObject(CalendarViewModel())
}
