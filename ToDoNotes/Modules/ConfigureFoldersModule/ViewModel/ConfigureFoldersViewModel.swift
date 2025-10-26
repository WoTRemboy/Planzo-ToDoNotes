//
//  ConfigureFoldersViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 26/10/2025.
//

import SwiftUI

final class ConfigureFoldersViewModel: ObservableObject {
    @Published internal var active: Folder?
    @Published internal var systemfolders: [Folder] = []
    @Published internal var folders: [Folder] = []
    
    @Published internal var showingChangeNameView: Bool = false
    
    init() {
        loadAllFolders()
    }
    
    private func loadAllFolders() {
        folders = FolderCoreDataService.shared.loadFolders()
        systemfolders = FolderCoreDataService.shared.loadFolders(onlySystem: true)
    }
    
    internal func updateFoldersOrderOnDisappear() {
        for (index, folder) in folders.enumerated() {
            var updated = folder
            updated.order = index
            FolderCoreDataService.shared.updateFolder(updated, color: folder.color)
        }
    }
    
    internal func moveFolder(fromOffsets: IndexSet, toOffset: Int) {
        folders.move(fromOffsets: fromOffsets, toOffset: toOffset)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    internal func showingChangeNameViewToggle() {
        showingChangeNameView.toggle()
    }
}
