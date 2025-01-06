//
//  TodayNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct TodayNavBar: View {
    private let date: String
    private let day: String
    
    init(date: String, day: String) {
        self.date = date
        self.day = day
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
            
            Text(day)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
    }
    
    private var buttons: some View {
        HStack(spacing: 20) {
            // Search Button
            Button {
                // Action for search button
            } label: {
                Image.NavigationBar.search
            }
            
            // Favorites Button
            Button {
                // Action for favorites button
            } label: {
                Image.NavigationBar.favorites
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    TodayNavBar(date: "18 January", day: "Sun")
        .environmentObject(TodayViewModel())
}
