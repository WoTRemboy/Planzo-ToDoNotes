//
//  TaskManagementNavBar.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

struct TaskManagementNavBar: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    private var onDismiss: () -> Void
    
    init(viewModel: TaskManagementViewModel,
         onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }
    
    internal var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top
            
            ZStack(alignment: .top) {
                Color.BackColors.backDefault
                    .shadow(color: Color.ShadowColors.shadowDefault, radius: 15, x: 0, y: 5)
                
                VStack(spacing: 0) {
                    HStack {
                        backButton
                        titleLabel
                        moreButton
                    }
                }
                .padding(.top, topInset + 9.5)
            }
            .ignoresSafeArea(edges: .top)
        }
        .frame(height: 48)
    }
    
    private var backButton: some View {
        Button {
            onDismiss()
        } label: {
            Image.NavigationBar.hide
                .resizable()
                .frame(width: 24, height: 24)
        }
        .padding(.leading)
    }
    
    private var titleLabel: some View {
        HStack(spacing: 4) {
            Text(Texts.TaskManagement.today)
                .font(.system(size: 22, weight: .bold))
                .padding(.leading)
            
            Text(viewModel.todayDate.shortDate)
                .font(.system(size: 22, weight: .bold))
            
            Text(viewModel.todayDate.shortWeekday)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelSecondary)
                .padding(.trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var shareButton: some View {
        Button {
            // Share Action
        } label: {
            Image.NavigationBar.share
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.clear)
                .frame(width: 22, height: 22)
        }
        .disabled(true)
        .padding(.trailing)
    }
    
    private var moreButton: some View {
        Menu {
            Button {
                // Complete Status Action
            } label: {
                Label {
                    Text(Texts.TaskManagement.ContextMenu.complete)
                } icon: {
                    Image.NavigationBar.uncompleted
                        .renderingMode(.template)
                }
            }
            
            Button {
                // Dublicate Task Action
            } label: {
                Label {
                    Text(Texts.TaskManagement.ContextMenu.dublicate)
                } icon: {
                    Image.NavigationBar.copy
                        .renderingMode(.template)
                }
            }
            
            Section {
                Button {
                    // Set Important Action
                } label: {
                    Label {
                        Text(Texts.TaskManagement.ContextMenu.important)
                    } icon: {
                        Image.NavigationBar.favorite
                            .renderingMode(.template)
                    }
                }
                
                Button {
                    // Pin Task Action
                } label: {
                    Label {
                        Text(Texts.TaskManagement.ContextMenu.pin)
                    } icon: {
                        Image.NavigationBar.pin
                            .renderingMode(.template)
                    }
                }
                
                Button(role: .destructive) {
                    // Delete Task Action
                } label: {
                    Label {
                        Text(Texts.TaskManagement.ContextMenu.delete)
                    } icon: {
                        Image.NavigationBar.trash
                            .renderingMode(.template)
                    }
                }
            }
        } label: {
            Image.NavigationBar.more
                .resizable()
                .frame(width: 24, height: 24)
        }
        .padding(.trailing)
    }
}

#Preview {
    TaskManagementNavBar(
        viewModel: TaskManagementViewModel(),
        onDismiss: {})
}
