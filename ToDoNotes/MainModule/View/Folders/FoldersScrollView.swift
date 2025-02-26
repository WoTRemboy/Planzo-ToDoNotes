//
//  FoldersScrollView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct FoldersScrollView: View {
    
    @EnvironmentObject private var viewModel: MainViewModel
    @Namespace private var animation
    
    internal var body: some View {
        HStack(spacing: 8) {
            folderMenu
            
            Divider()
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .frame(height: 36)
                .offset(x: 8)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    scrollContent(proxy: proxy)
                }
            }
            .scrollIndicators(.hidden)
        }
        
    }
    
    @ViewBuilder
    private func scrollContent(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(Folder.allCases, id: \.self) { folder in
                FolderCell(name: folder.name,
                           color: folder.color,
                           selected: viewModel.compareFolders(with: folder), namespace: animation)
                .id(folder)
                .onTapGesture {
                    viewModel.setFolder(to: folder)
                    withAnimation {
                        proxy.scrollTo(folder, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 36)
        .padding(.horizontal)
    }
    
    private var folderMenu: some View {
        Menu {
            allFoldersPicker
        } label: {
            Image.Folder.navBar
                .frame(width: 24, height: 24)
        }
        .padding(.leading)
    }
    
    private var allFoldersPicker: some View {
        Picker(Texts.MainPage.Folders.title,
               selection: $viewModel.selectedFolder.animation(.easeInOut(duration: 0.2))) {
            
            ForEach(Folder.allCases, id: \.self) { folder in
                Label {
                    Text(folder.name)
                } icon: {
                    folder.lockedIcon
                }
            }
        }
    }
}

#Preview {
    FoldersScrollView()
        .environmentObject(MainViewModel())
}
