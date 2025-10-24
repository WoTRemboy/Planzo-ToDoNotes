//
//  ConfigureSelectedFolderView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 24/10/2025.
//

import SwiftUI

struct ConfigureSelectedFolderView: View {
    
    @State private var folder: Folder
    
    init(folder: Folder) {
        self.folder = folder
    }
    
    internal var body: some View {
        paramsList
            .customNavBarItems(
                title: folder.localizedName,
                showBackButton: true)
    }
    
    private var paramsList: some View {
        VStack(spacing: 0) {
            let params = FolderConfig.allCases
            ForEach(params, id: \.self) { type in
                SelectedFolderSettingFormView(folder: folder, type: type, last: type == params.last)
            }
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding()
    }
}

#Preview {
    ConfigureSelectedFolderView(folder: .mock())
}
