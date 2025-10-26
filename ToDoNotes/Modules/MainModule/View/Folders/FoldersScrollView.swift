//
//  FoldersScrollView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

/// A horizontally scrolling view of folders, allowing users to quickly filter tasks.
/// Includes a menu button for selecting folders from a picker.
struct FoldersScrollView: View {
    
    @EnvironmentObject private var viewModel: MainViewModel
    @EnvironmentObject private var authService: AuthNetworkService
    /// Namespace for matched geometry effects between selected folders.
    @Namespace private var animation
    
    // MARK: - Body
    
    internal var body: some View {
        HStack(spacing: 8) {
            // Folder menu button (opens a Picker)
            folderMenu
            
            // Vertical divider between the menu and the scrolling folders
            Divider()
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .frame(height: 36)
                .offset(x: 8)
            
            // Scrollable list of folders
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    scrollContent(proxy: proxy)
                }
            }
            .scrollIndicators(.hidden)
            
//            Divider()
//                .foregroundStyle(Color.LabelColors.labelPrimary)
//                .frame(height: 36)
//                .offset(x: -8)
//            
//            configFoldersButton
        }
    }
    
    // MARK: - Scroll Content
    
    /// Displays all folders inside a horizontally scrolling `HStack`.
    /// Highlights the selected folder with a visual effect.
    @ViewBuilder
    private func scrollContent(proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(viewModel.folders.filter { !$0.shared }, id: \.id) { folder in
                FolderCell(folder: folder,
                           selected: viewModel.compareFolders(with: folder), namespace: animation)
                .id(folder)
                .onTapGesture {
                    viewModel.setFolder(to: folder)
                    // Smoothly scrolls to the selected folder
                    withAnimation {
                        proxy.scrollTo(folder, anchor: .center)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.folders)
        .frame(height: 36)
        .padding(.horizontal)
    }
    
    // MARK: - Folder Menu
    
    /// Displays a menu button that opens a `Picker` for choosing a folder.
    private var folderMenu: some View {
        Menu {
            allFoldersPicker
        } label: {
            Image.Folder.navBar
                .frame(width: 24, height: 24)
        }
        .padding(.leading)
    }
    
    /// The folder picker displayed inside the menu, listing all available folders.
    @ViewBuilder
    private var allFoldersPicker: some View {
        Picker(Texts.Folders.title,
               selection: $viewModel.selectedFolder.animation(.easeInOut(duration: 0.2))) {
            ForEach(viewModel.folders.filter { !$0.shared }, id: \.id) { folder in
                Label {
                    Text(folder.localizedName)
                } icon: {
                    folder.locked ? Image.Folder.locked : nil
                }
                .tag(Optional(folder))
            }
        }
        
        CustomNavLink(
            destination: ConfigureFoldersView()
        ) {
            Label {
                Text(Texts.Folders.Configure.title)
            } icon: {
                Image.Folder.config
            }
        }
    }
    
    private var configFoldersButton: some View {
        CustomNavLink(
            destination: ConfigureFoldersView()
        ) {
            Image.Folder.config
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .padding(.trailing)
    }
}

// MARK: - Preview

#Preview {
    FoldersScrollView()
        .environmentObject(MainViewModel())
        .environmentObject(AuthNetworkService())
}
