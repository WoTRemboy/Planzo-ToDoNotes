//
//  MainView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct MainView: View {
    internal var body: some View {
        ScrollView {
            content
        }
        .disabled(true)
        .overlay {
            CustomNavBar(title: Texts.MainPage.title)
        }
    }
    
    private var content: some View {
        Text(Texts.MainPage.placeholder)
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 200)
    }
}

#Preview {
    MainView()
}
