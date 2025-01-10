//
//  MainView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject private var viewModel: MainViewModel
    @State private var taskManagementHeight: CGFloat = 15
    
    internal var body: some View {
        ZStack {
            content
            plusButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            CustomNavBar(title: Texts.MainPage.title)
        }
        .sheet(isPresented: $viewModel.showingTaskEditView) {
            TaskManagementView(taskManagementHeight: $taskManagementHeight)
                .presentationDetents([.height(80 + taskManagementHeight)])
                .presentationDragIndicator(.visible)
        }
    }
        
    private var content: some View {
        Text(Texts.MainPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .frame(maxWidth: .infinity)
    }
    
    private var plusButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    viewModel.showingTaskEditView.toggle()
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
    MainView()
        .environmentObject(MainViewModel())
}
