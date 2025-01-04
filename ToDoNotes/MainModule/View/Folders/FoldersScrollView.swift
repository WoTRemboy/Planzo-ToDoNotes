//
//  FoldersScrollView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct FoldersScrollView: View {
    
    @EnvironmentObject private var viewModel: MainViewModel
    
    internal var body: some View {
        ScrollView(.horizontal) {
            content
        }
        .scrollIndicators(.hidden)
    }
    
    private var content: some View {
        HStack(spacing: 8) {
            folderMenu
            scrollFolders
        }
        .frame(height: 36)
        .padding(.horizontal)
    }
    
    private var folderMenu: some View {
        Menu {
            folderPicker
        } label: {
            Image.Folder.navBar
                .frame(width: 24, height: 24)
        }
    }
    
    private var folderPicker: some View {
        Picker(Texts.MainPage.Folders.title,
               selection: $viewModel.selectedFolder.animation(.easeInOut(duration: 0.2))) {
            
            ForEach(Folder.allCases.dropLast(), id: \.self) { folder in
                Label {
                    Text(folder.name)
                } icon: {
                    Image.Folder.unlocked
                }
            }
            Divider()

            Label {
                Text(Folder.passwords.name)
            } icon: {
                Image.Folder.locked
            }
            .tag(Folder.passwords)
        }
    }
    
    private var scrollFolders: some View {
        ForEach(Folder.allCases, id: \.self) { folder in
            FolderCell(name: folder.name,
                       selected: viewModel.compareFolders(with: folder))
            .onTapGesture {
                viewModel.setFolder(to: folder)
            }
        }
    }
}

#Preview {
    FoldersScrollView()
        .environmentObject(MainViewModel())
}
