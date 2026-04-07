//
//  BackgroundModifier.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/27/26.
//

import SwiftUI

private struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(Color.BackColors.backDefaultGlass)
                .ignoresSafeArea(.keyboard)
        } else {
            content
                .shadow(color: Color.ShadowColors.taskSection, radius: 10, x: 2, y: 2)
                .background(Color.BackColors.backDefault)
        }
    }
}

private struct CalendarBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.background(Color.BackColors.backDefaultGlass)
        } else {
            content
                .background(Color.BackColors.backDefault)
        }
    }
}

extension View {
    func defaultBackgroundStyle() -> some View {
        modifier(BackgroundModifier())
    }
    
    func calendarBackgroundStyle() -> some View {
        modifier(CalendarBackgroundModifier())
    }
}
