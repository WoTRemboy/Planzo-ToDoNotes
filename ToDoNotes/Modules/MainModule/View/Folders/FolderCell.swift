//
//  FolderCell.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

/// A single cell representing a folder in the folders scroll view.
/// Highlights the selected folder and shows a background color based on selection.
struct FolderCell: View {
    
    // MARK: - Properties
    
    /// Folder data model.
    private let folder: Folder
    /// Indicates whether this folder is currently selected.
    private let selected: Bool
    /// Namespace for matched geometry animations between folders.
    private let namespace: Namespace.ID
    
    // MARK: - Initialization
    
    init(folder: Folder, selected: Bool, namespace: Namespace.ID) {
        self.folder = folder
        self.selected = selected
        self.namespace = namespace
    }
    
    // MARK: - Body
    
    internal var body: some View {
        ZStack {
            // Background depending on selection
            if selected {
                backgroundRectangle
            } else {
                emptyRectangle
            }
            folderTitle
        }
    }
    
    // MARK: - Components
    
    private var folderTitle: some View {
        HStack(alignment: .bottom, spacing: 2) {
            if !folder.system || !folder.shared {
                nameLabel
            }
            
            if folder.shared {
                sharedIcon
            }
        }
        .background(alignment: .bottom) {
            underline
                .offset(y: 4)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
    }
    
    /// Displays the name of the folder with the appropriate color and underline.
    private var nameLabel: some View {
        Text(folder.name)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(textColor)
    }
    
    private var sharedIcon: some View {
        Image.Folder.shared
            .renderingMode(.template)
            .resizable()
            .foregroundStyle(textColor)
            .frame(width: 24, height: 24)
    }
    
    /// Displays an underline under the folder name if not selected.
    private var underline: some View {
        Rectangle()
            .foregroundStyle(selected ? .clear : folder.color.rgbToColor())
        
            .frame(maxWidth: .infinity)
            .frame(height: 4)
            .clipShape(.rect(cornerRadius: 3))
    }
    
    /// Displays a rounded colored background if the folder is selected.
    private var backgroundRectangle: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(selected ? folder.color.rgbToColor() : .clear)
            .animation(.easeInOut(duration: 0.2), value: selected)
            .transition(.blurReplace)
    }
    
    /// Displays a transparent rectangle when not selected (for layout stability).
    private var emptyRectangle: some View {
        Rectangle()
            .foregroundStyle(Color.clear)
    }
    
    private var textColor: Color {
        if selected, folder.system {
            Color.LabelColors.labelReversed     // Reversed color for All folder
        } else if selected {
            Color.LabelColors.labelBlack        // Black color for selected cell
        } else {
            Color.LabelColors.labelDetails      // Light grey color for not selected cell
        }
    }
}

// MARK: - Preview

#Preview {
    let mockFolder = Folder.mock(system: true, shared: true)
    FolderCell(folder: mockFolder, selected: true, namespace: Namespace().wrappedValue)
}
