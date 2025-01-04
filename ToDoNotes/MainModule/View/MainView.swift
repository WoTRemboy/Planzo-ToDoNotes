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
        TabView(selection: $viewModel.selectedTab) {
            ScrollView {
                content
            }
            .disabled(true)
            .overlay {
                CustomNavBar(title: Texts.MainPage.title)
            }
            
            .tabItem {
                Image.Placeholder.tabbarIcon
                    .renderingMode(.template)
                Text(Texts.Tabbar.main)
            }
            .tag(0)
            
            TodayView()
                .tabItem {
                    Image.Placeholder.tabbarIcon
                        .renderingMode(.template)
                    Text(Texts.Tabbar.today)
                }
                .tag(1)
            
            CalendarView()
                .tabItem {
                    Image.Placeholder.tabbarIcon
                        .renderingMode(.template)
                    Text(Texts.Tabbar.calendar)
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image.Placeholder.tabbarIcon
                        .renderingMode(.template)
                    Text(Texts.Tabbar.settings)
                }
                .tag(3)
        }
        .accentColor(.LabelColors.labelSecondary)
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
        .environmentObject(MainViewModel())
}
