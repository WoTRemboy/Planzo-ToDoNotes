//
//  MainView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject private var viewModel: MainViewModel
    
    internal var body: some View {
        ZStack {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            CustomNavBar(title: Texts.MainPage.title)
        }
    }
        
    
    private var content: some View {
        Text(Texts.MainPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
}
