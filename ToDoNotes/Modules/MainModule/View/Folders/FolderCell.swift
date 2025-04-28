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
            
            // Folder title
            nameLabel
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
        }
    }
    
    // MARK: - Components
    
    /// Displays the name of the folder with the appropriate color and underline.
    private var nameLabel: some View {
        let color: Color
        if selected && folder == .all {
            color = Color.LabelColors.labelReversed     // Reversed color for All folder
        } else if selected {
            color = Color.LabelColors.labelBlack        // Black color for selected cell
        } else {
            color = Color.LabelColors.labelDetails      // Light grey color for not selected cell
        }
        
        return Text(folder.name)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(color)
            .background(alignment: .bottom) {
                underline
                    .offset(y: 4)
            }
    }
    
    /// Displays an underline under the folder name if not selected.
    private var underline: some View {
        Rectangle()
            .foregroundStyle(selected ? .clear : folder.color)
        
            .frame(maxWidth: .infinity)
            .frame(height: 4)
            .clipShape(.rect(cornerRadius: 3))
    }
    
    /// Displays a rounded colored background if the folder is selected.
    private var backgroundRectangle: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(selected ? folder.color : .clear)
            .animation(.easeInOut(duration: 0.2), value: selected)
            .transition(.blurReplace)
    }
    
    /// Displays a transparent rectangle when not selected (for layout stability).
    private var emptyRectangle: some View {
        Rectangle()
            .foregroundStyle(Color.clear)
    }
}

// MARK: - Preview

#Preview {
    FolderCell(folder: .lists, selected: true, namespace: Namespace().wrappedValue)
}
