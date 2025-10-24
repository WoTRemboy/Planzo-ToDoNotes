//
//  ConfigureFoldersView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 21/10/2025.
//

import SwiftUI

struct ConfigureFoldersView: View {
    
    @State private var active: Folder?
    @State private var systemfolders: [Folder] = []
    @State private var folders: [Folder] = []
    
    internal var body: some View {
        ScrollView(.vertical) {
            foldersList
            dragLabel
        }
        .customNavBarItems(
            title: Texts.Folders.Configure.fullTitle,
            showBackButton: true)
        .onAppear {
            folders = FolderCoreDataService.shared.loadFolders()
            systemfolders = FolderCoreDataService.shared.loadFolders(onlySystem: true)
        }
        .onDisappear {
            for (index, folder) in folders.enumerated() {
                var updated = folder
                updated.order = index
                FolderCoreDataService.shared.updateFolder(updated, color: folder.color)
            }
        }
    }
    
    private var foldersList: some View {
        LazyVStack(spacing: 0) {
            systemVStack
            reordableVStack
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding()
        .scrollContentBackground(.hidden)
        .reorderableForEachContainer(active: $active)
    }
    
    @ViewBuilder
    private var systemVStack: some View {
        ForEach(systemfolders, id: \.self) { item in
            FolderFormView(folder: item)
        }
    }
    
    private var reordableVStack: some View {
        ReorderableForEach(folders, active: $active) { item in
            if !item.system {
                CustomNavLink(
                    destination: ConfigureSelectedFolderView(folder: item),
                    label: {
                        FolderFormView(folder: item, last: item == folders.last)
                    })
            }
        } preview: { _ in
        } moveAction: { from, to in
            folders.move(fromOffsets: from, toOffset: to)
        }
    }
    
    private var dragLabel: some View {
        Text(Texts.Folders.Configure.dragAndDrop)
            .foregroundStyle(Color.LabelColors.labelDetails)
            .font(.system(size: 15, weight: .regular))
            .padding(.top, 8)
    }
    
    var shape: some Shape {
        RoundedRectangle(cornerRadius: 20)
    }
}

#Preview {
    ConfigureFoldersView()
}
