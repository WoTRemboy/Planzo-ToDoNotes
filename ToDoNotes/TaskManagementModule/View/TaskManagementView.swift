//
//  TaskManagementView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/6/25.
//

import SwiftUI

struct TaskManagementView: View {
    
    @FocusState private var titleFocused
    
    @State private var titleText: String = String()
    @State private var discriptionText: String = String()
    
    internal var body: some View {
        VStack(spacing: 0) {
            sliderLine
            titleInput
            descriptionInput
            
            Spacer()
            buttons
        }
        .frame(height: 122)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var sliderLine: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .foregroundStyle(Color.LabelColors.labelTertiary)
            .frame(width: 36, height: 5)
    }
    
    private var titleInput: some View {
        TextField(Texts.TaskManagement.titlePlaceholder, text: $titleText)
            .font(.system(size: 18, weight: .regular))
            .lineLimit(1)
            .padding(.top, 20)
        
            .focused($titleFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    titleFocused = true
                }
            }
    }
    
    private var descriptionInput: some View {
        TextField(Texts.TaskManagement.descriprionPlaceholder,
                  text: $discriptionText,
                  axis: .vertical)
        .lineLimit(1...5)
        
        .font(.system(size: 15, weight: .light))
        .padding(.top, 10)
    }
    
    private var buttons: some View {
        HStack(spacing: 16) {
            calendarButton
            checkButton
            moreButton
            
            Spacer()
            acceptButton
        }
    }
    
    private var calendarButton: some View {
        Button {
            // Action for calendar button
        } label: {
            Image.TaskManagement.EditTask.calendar
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    private var checkButton: some View {
        Button {
            // Action for check button
        } label: {
            Image.TaskManagement.EditTask.check
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    private var moreButton: some View {
        Button {
            // Action for more button
        } label: {
            Image.TaskManagement.EditTask.more
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    private var acceptButton: some View {
        Button {
            // Action for accept button
        } label: {
            Image.TaskManagement.EditTask.accept
                .resizable()
                .frame(width: 30, height: 30)
        }
    }
}

#Preview {
    TaskManagementView()
}
