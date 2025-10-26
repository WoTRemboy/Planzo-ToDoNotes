//
//  ConfigureSelectedFolderView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 24/10/2025.
//

import SwiftUI

struct ConfigureSelectedFolderView: View {
    
    @ObservedObject var viewModel: ConfigureFoldersViewModel
    private let folder: Folder?
    
    @State private var titleFocused: Bool = false
    
    init(viewModel: ConfigureFoldersViewModel, folder: Folder?) {
        self.viewModel = viewModel
        self.folder = folder
    }
    
    internal var body: some View {
        VStack(spacing: 24) {
            paramsList
            createDeleteButton
        }
        .padding()
        .customNavBarItems(
            title: folder?.localizedName ?? Texts.Folders.Configure.newFolder,
            showBackButton: true,
            position: .center)
        .popView(isPresented: $viewModel.showingChangeNameView, onTap: {
            titleFocused = false
        }, onDismiss: {} ) {
            changeTitleView
        }
    }
    
    private var paramsList: some View {
        VStack(spacing: 0) {
            let params = FolderConfig.allCases
            ForEach(params, id: \.self) { type in
                Button {
                    viewModel.showingChangeNameViewToggle()
                } label: {
                    SelectedFolderSettingFormView(folder: folder, type: type, last: type == params.last)
                }
            }
        }
        .clipShape(.rect(cornerRadius: 10))
    }
    
    private var createDeleteButton: some View {
        if folder != nil {
            CreateDeleteFolderButtonView(type: .change) {}
        } else {
            CreateDeleteFolderButtonView(type: .create) {}
        }
    }
    
    private var changeTitleView: some View {
        ConfigureFolderTitleView(
            title: folder?.name,
            focusField: $titleFocused,
            primaryAction: { title in
                viewModel.showingChangeNameViewToggle()
            },
            secondaryAction: {
                viewModel.showingChangeNameViewToggle()
            })
    }
}

#Preview {
    ConfigureSelectedFolderView(viewModel: .init(), folder: .mock())
}
