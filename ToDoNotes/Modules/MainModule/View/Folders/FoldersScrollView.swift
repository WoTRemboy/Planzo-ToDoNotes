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
    @Namespace private var glassNamespace
    
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
        }
    }
    
    // MARK: - Scroll Content
    
    /// Displays all folders inside a horizontally scrolling `HStack`.
    /// Highlights the selected folder with a visual effect.
    @ViewBuilder
    private func scrollContent(proxy: ScrollViewProxy) -> some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 10) {
                LazyHStack(spacing: 10) {
                    ForEach(viewModel.folders, id: \.id) { folder in
                        folderBubble(folder)
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
            }
            .glassEffectUnion(id: "FoldersBubbles", namespace: glassNamespace)
            .padding(.horizontal)
            .padding(.vertical, 2)
            .animation(.easeInOut(duration: 0.2), value: viewModel.folders)
        } else {
            LazyHStack(alignment: .bottom, spacing: 0) {
                ForEach(viewModel.folders, id: \.id) { folder in
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
    }

    @available(iOS 26.0, *)
    private func folderBubble(_ folder: Folder) -> some View {
        let isSelected = viewModel.compareFolders(with: folder)
        let color = folderColor(folder)
        let textColor = folderTextColor(folder: folder, selected: isSelected, color: color)

        return HStack(alignment: .center, spacing: 6) {
            if !folder.shared {
                Text(folder.localizedName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(textColor)
            }

            if folder.shared {
                Image.Folder.shared
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(textColor)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isSelected ? color : Color.BackColors.backElevated)
                .shadow(color: Color.ShadowColors.navBar, radius: 6, x: 0, y: 0)
        )
        .contentShape(.rect)
        .glassEffect(.clear.interactive())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private func folderColor(_ folder: Folder) -> Color {
        if folder.system {
            Color.FolderColors.all
        } else {
            folder.color.rgbToColor()
        }
    }

    private func folderTextColor(folder: Folder, selected: Bool, color: Color) -> Color {
        if selected, folder.system {
            return Color.LabelColors.labelReversed
        }
        if selected {
            return Color.LabelColors.labelBlack
        }
        return color
    }
    
    // MARK: - Folder Menu
    
    /// Displays a menu button that opens a `Picker` for choosing a folder.
    private var folderMenu: some View {
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 0) {
                    Menu {
                        allFoldersPicker
                    } label: {
                        Image.Folder.navBar
                            .frame(width: 20, height: 20)
                            .padding(12)
                    }
                }
                .glassEffect(.regular.interactive())
            } else {
                Menu {
                    allFoldersPicker
                } label: {
                    Image.Folder.navBar
                        .frame(width: 24, height: 24)
                }
            }
        }
        .padding(.leading)
    }
    
    /// The folder picker displayed inside the menu, listing all available folders.
    @ViewBuilder
    private var allFoldersPicker: some View {
        Picker(Texts.Folders.title,
               selection: $viewModel.selectedFolder.animation(.easeInOut(duration: 0.2))) {
            ForEach(viewModel.folders, id: \.id) { folder in
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
