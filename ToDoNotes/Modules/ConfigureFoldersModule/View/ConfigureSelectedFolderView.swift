//
//  ConfigureSelectedFolderView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 24/10/2025.
//

import SwiftUI

struct ConfigureSelectedFolderView: View {
    
    @State private var folder: Folder?
    private let title: String
    
    init(folder: Folder?) {
        self.folder = folder
        
        if let folder {
            title = folder.localizedName
        } else {
            title = Texts.Folders.Configure.newFolder
        }
    }
    
    internal var body: some View {
        VStack(spacing: 24) {
            paramsList
            createDeleteButton
        }
        .padding()
        .customNavBarItems(
            title: title,
            showBackButton: true,
            position: .center)
    }
    
    private var paramsList: some View {
        VStack(spacing: 0) {
            let params = FolderConfig.allCases
            ForEach(params, id: \.self) { type in
                SelectedFolderSettingFormView(folder: folder, type: type, last: type == params.last)
            }
        }
        .clipShape(.rect(cornerRadius: 10))
    }
    
    private var createDeleteButton: some View {
        if folder != nil {
            CreateDeleteFolderButtonView(type: .delete) {}
        } else {
            CreateDeleteFolderButtonView(type: .create) {}
        }
    }
}

#Preview {
    ConfigureSelectedFolderView(folder: .mock())
}
