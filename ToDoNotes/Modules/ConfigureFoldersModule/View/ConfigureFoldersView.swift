//
//  ConfigureFoldersView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 21/10/2025.
//

import SwiftUI
import Combine

struct ConfigureFoldersView: View {
    
    @StateObject private var viewModel = ConfigureFoldersViewModel()
        
    internal var body: some View {
        ZStack {
            ScrollView(.vertical) {
                foldersList
                dragLabel
            }
            .safeAreaInset(edge: .bottom) {
                safeAreaContent
            }
        }
        .customNavBarItems(
            title: Texts.Folders.Configure.fullTitle,
            showBackButton: true,
            position: .center)
        .onDisappear {
            viewModel.updateFoldersOrderOnDisappear()
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
        .reorderableForEachContainer(active: $viewModel.active)
    }
    
    @ViewBuilder
    private var systemVStack: some View {
        ForEach(viewModel.systemfolders, id: \.self) { item in
            FolderFormView(folder: item)
        }
    }
    
    private var reordableVStack: some View {
        ReorderableForEach(viewModel.folders, active: $viewModel.active) { item in
            if !item.system {
                CustomNavLink(
                    destination: ConfigureSelectedFolderView(viewModel: viewModel, folder: item),
                    label: {
                        FolderFormView(folder: item, last: item == viewModel.folders.last)
                    })
            }
        } preview: { _ in
        } moveAction: { from, to in
            viewModel.moveFolder(fromOffsets: from, toOffset: to)
        }
    }
    
    private var dragLabel: some View {
        Text(Texts.Folders.Configure.dragAndDrop)
            .foregroundStyle(Color.LabelColors.labelDetails)
            .font(.system(size: 15, weight: .regular))
            .padding(.top, 8)
    }
    
    private var safeAreaContent: some View {
        VStack(spacing: 0) {
            CustomNavLink(
                destination: ConfigureSelectedFolderView(viewModel: viewModel, folder: nil),
                label: {
                    createFolderView
                })
                .padding(.bottom, hasNotch() ? 0 : 16)
        }
        .frame(maxWidth: .infinity)
        .background {
            Color.SupportColors.supportNavBar
                .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: -5)
                .ignoresSafeArea()
        }
    }
    
    private var createFolderView: some View {
        Text(Texts.Folders.Configure.create)
            .font(.system(size: 17, weight: .medium))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .lineLimit(1)
        
            .foregroundColor(Color.LabelColors.labelReversed)
            .background(Color.LabelColors.labelPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        
            .frame(height: 50)
            .minimumScaleFactor(0.4)
            .padding([.horizontal, .top], 16)
    }
    
    var shape: some Shape {
        RoundedRectangle(cornerRadius: 20)
    }
}

#Preview {
    ConfigureFoldersView()
}
