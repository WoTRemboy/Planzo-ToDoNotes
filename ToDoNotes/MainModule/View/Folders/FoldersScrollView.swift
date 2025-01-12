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
            allFoldersPicker
            unlockedFoldersPicker
            lockedFoldersPicker
        } label: {
            Image.Folder.navBar
                .frame(width: 24, height: 24)
        }
    }
    
    private var allFoldersPicker: some View {
        Picker(Texts.MainPage.Folders.title,
               selection: $viewModel.selectedFolder.animation(.easeInOut(duration: 0.2))) {
            
            Label {
                Text(Folder.all.name)
            } icon: {
                Image.Folder.unlocked
            }
            .tag(Folder.all)
        }
    }
    
    private var unlockedFoldersPicker: some View {
        Picker(Texts.MainPage.Folders.title,
               selection: $viewModel.selectedFolder.animation(.easeInOut(duration: 0.2))) {
            
            ForEach(Folder.allCases.dropFirst().dropLast(), id: \.self) { folder in
                Label {
                    Text(folder.name)
                } icon: {
                    Image.Folder.unlocked
                }
            }
        }
    }
    
    private var lockedFoldersPicker: some View {
        Picker(Texts.MainPage.Folders.title,
               selection: $viewModel.selectedFolder.animation(.easeInOut(duration: 0.2))) {
            
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
