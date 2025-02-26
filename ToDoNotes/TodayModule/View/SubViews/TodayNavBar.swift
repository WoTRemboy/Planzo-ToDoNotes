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
            Text(date)
                .font(.system(size: 22, weight: .bold))
            
            Text(day)
                .font(.system(size: 22, weight: .bold))
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
                    .resizable()
                    .frame(width: 26, height: 26)
            }
            
            // Favorites Button
            Button {
                // Action for favorites button
            } label: {
                Image.NavigationBar.favorites
                    .resizable()
                    .frame(width: 26, height: 26)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    TodayNavBar(date: "18 January", day: "Sun")
        .environmentObject(TodayViewModel())
}
