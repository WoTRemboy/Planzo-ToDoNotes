//
//  TaskManagementNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

struct TaskManagementNavBar: View {
    
    private var title: String
    private var dayName: String
    private var onDismiss: () -> Void
    
    init(title: String,
         dayName: String,
         onDismiss: @escaping () -> Void) {
        self.title = title
        self.dayName = dayName
        self.onDismiss = onDismiss
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            HStack {
                backButton
                titleLabel
                shareButton
            }
        }
        .frame(height: 46.5)
    }
    
    private var backButton: some View {
        Button {
            onDismiss()
        } label: {
            Image.NavigationBar.back
                .resizable()
                .frame(width: 22, height: 22)
        }
        .padding(.leading)
    }
    
    private var titleLabel: some View {
        HStack(spacing: 4) {
            Text(Texts.TaskManagement.today)
                .font(.system(size: 17, weight: .regular))
                .padding(.leading)
            
            Text(title)
                .font(.system(size: 17, weight: .regular))
            
            Text(dayName)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelSecondary)
                .padding(.trailing)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var shareButton: some View {
        Button {
            // Share Button action
        } label: {
            Image.NavigationBar.share
                .resizable()
                .frame(width: 22, height: 22)
        }
        .padding(.trailing)
    }
}

#Preview {
    TaskManagementNavBar(
        title: "November 18",
        dayName: "Sun") {}
}
