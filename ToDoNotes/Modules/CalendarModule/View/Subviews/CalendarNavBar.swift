//
//  CalendarNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

/// A custom navigation bar for the Calendar page.
struct CalendarNavBar: View {
    
    // MARK: - Properties
    
    /// CalendarViewModel from environment to handle date and navigation actions.
    @EnvironmentObject private var viewModel: CalendarViewModel
    @Namespace private var glassNamespace

    /// Label for the "Today" button.
    private let date: String
    /// Currently selected month and year.
    private let monthYear: Date
        
    // MARK: - Initialization
    
    /// Initializes a new calendar navigation bar.
    /// - Parameters:
    ///   - date: Text label for the 'today' button.
    ///   - monthYear: Date representing the currently selected month and year.
    init(date: String, monthYear: Date) {
        self.date = date
        self.monthYear = monthYear
    }
    
    // MARK: - Body
    
    internal var body: some View {
        GeometryReader { proxy in
            // Handling safe area.
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                // Background color and shadow of the navigation bar.
                background
                
                // Main horizontal layout containing title and buttons.
                HStack {
                    titleLabel
                    calendarButton
                }
                .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    // MARK: - Subviews
    
    /// Displays the title with "Today" button and the selected month and year.
    private var titleLabel: some View {
        HStack(spacing: 8) {
            // "Today" button to reset the selected date back to today.
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.restoreTodayDate()
                }
            } label: {
                Text(date)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
            }
            
            // Displays the selected month and year.
            Text(monthYear.longMonthYear)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelSecondary)
                .contentTransition(.numericText(value: monthYear.timeIntervalSince1970))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
    }
    
    /// Displays action buttons like calendar picker.
    private var calendarButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 6) {
                    HStack(spacing: 6) {
                        glassActionButton(content: calendarButtonContent,
                                          action: calendarButtonAction)
                    }
                }
            } else {
                HStack(spacing: 20) {
                    Button {
                        calendarButtonAction()
                    } label: {
                        calendarButtonContent
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var background: some View {
        if #available(iOS 26.0, *) {} else {
            Color.SupportColors.supportNavBar
                .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: 5)
        }
    }

    private var calendarButtonContent: some View {
        Image.NavigationBar.calendar
            .resizable()
            .frame(width: 26, height: 26)
    }

    private func calendarButtonAction() {
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.toggleShowingCalendarSelector()
        }
    }

    @available(iOS 26.0, *)
    @ViewBuilder
    private func glassActionButton<Content: View>(content: Content, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            content
                .padding(8)
        }
        .glassEffect(.regular.interactive())
        .glassEffectUnion(id: "CalendarNavBarActions", namespace: glassNamespace)
    }
}

// MARK: - Preview

#Preview {
    CalendarNavBar(date: "Today", monthYear: Date.now)
        .environmentObject(CalendarViewModel())
}
