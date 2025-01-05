//
//  TodayView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct TodayView: View {
    
    @EnvironmentObject private var viewModel: TodayViewModel
    
    private let todayDate = Date()
    
    internal var body: some View {
        ZStack {
            content
            plusButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            TodayNavBar(date: todayDate.shortDate, day: todayDate.shortWeekday)
        }
    }
    
    private var content: some View {
        Text(Texts.TodayPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .frame(maxWidth: .infinity)
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
    TodayView()
        .environmentObject(TodayViewModel())
}
