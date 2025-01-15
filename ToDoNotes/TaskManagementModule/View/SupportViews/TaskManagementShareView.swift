//
//  TaskManagementShareView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import SwiftUI

struct TaskManagementShareView: View {
        
    @State private var viewParam: Bool = false
    @State private var editParam: Bool = false
    
    internal var body: some View {
        ZStack {
            VStack {
                navBar
                paramsForm
                generateLinkButton
            }
            .zIndex(1)
            
            Rectangle()
                .foregroundStyle(Color.BackColors.backSheetView)
                .ignoresSafeArea()
        }
    }
    
    private var navBar: some View {
        HStack {
            Text(Texts.TaskManagement.ShareView.title)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelPrimary)
            
            Spacer()
            Button {
                // More button action
            } label: {
                Image.NavigationBar.more
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal)
    }
    
    private var paramsForm: some View {
        VStack(spacing: 3) {
            viewToggle
            editToggle
        }
        .padding([.top, .horizontal])
    }
    
    private var viewToggle: some View {
        ZStack {
            HStack {
                Toggle(isOn: $viewParam) {
                    Text(Texts.TaskManagement.ShareView.view)
                        .font(.system(size: 17, weight: .regular))
                }
            }
            .padding(.horizontal)
            .zIndex(1)
            
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.BackColors.backSecondary)
                .frame(height: 44)
        }
    }
    
    private var editToggle: some View {
        ZStack {
            HStack {
                Toggle(isOn: $editParam) {
                    Text(Texts.TaskManagement.ShareView.edit)
                        .font(.system(size: 17, weight: .regular))
                }
            }
            .padding(.horizontal)
            .zIndex(1)
            
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.BackColors.backSecondary)
                .frame(height: 44)
        }
    }
    
    private var generateLinkButton: some View {
        Button {
            // Action for generate link button
        } label: {
            ZStack {
                HStack {
                    Image.TaskManagement.EditTask.link
                        .resizable()
                        .frame(width: 22, height: 22)
                    
                    Text(Texts.TaskManagement.ShareView.link)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.LabelColors.labelReversed)
                }
                .zIndex(1)
                
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 50)
                    .foregroundStyle(Color.LabelColors.labelDetails)
            }
        }
        .padding(.horizontal)
        .padding(.top, 32)
    }
}

#Preview {
    TaskManagementShareView()
        .environmentObject(TaskManagementViewModel())
}
