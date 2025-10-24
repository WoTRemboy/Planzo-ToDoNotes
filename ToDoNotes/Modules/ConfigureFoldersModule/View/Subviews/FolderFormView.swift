//
//  FolderFormView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 21/10/2025.
//

import SwiftUI

struct FolderFormView: View {
    
    // MARK: - Properties
    
    private let folder: Folder
    /// Flag indicating whether this is the last row (hides bottom divider).
    private let last: Bool
    
    // MARK: - Initialization
        
    init(folder: Folder, last: Bool = false) {
        self.folder = folder
        self.last = last
    }
    
    // MARK: - Body
    
    internal var body: some View {
        HStack {
            leftLabel
            
            Spacer()
            
            if folder.system {
                Image.Subscription.premium
            }
            
            if !folder.visible {
                Image.Folder.hidden
                    .renderingMode(.template)
                    .foregroundStyle(Color.LabelColors.labelSecondary)
                    .frame(width: 20, height: 20)
            }
            
            if folder.locked {
                Image.Folder.unlocked
                    .renderingMode(.template)
                    .foregroundStyle(Color.LabelColors.labelSecondary)
                    .frame(width: 20, height: 20)
            }
            
            Image.Settings.chevron
                .resizable()
                .frame(width: 20, height: 20)
        }
        
        .padding(.horizontal, 14)
        .frame(height: 56)
        
        .background(alignment: .bottom) {
            if !last {
                Rectangle()
                    .foregroundStyle(Color.LabelColors.labelSecondary)
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)
            }
        }
        .background(Color.SupportColors.supportButton)
    }
    
    // MARK: - Components
    
    /// Label view displaying the optional image and title on the left.
    private var leftLabel: some View {
        HStack(alignment: .center, spacing: 8) {
            color
                .clipShape(.circle)
                .frame(width: 20, height: 20)
            
            Text(folder.localizedName)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .lineLimit(1)
        }
    }
    
    private var color: Color {
        if folder.system {
            return Color.FolderColors.all
        }
        return folder.color.rgbToColor()
    }
}

// MARK: - Preview

#Preview {
    FolderFormView(folder: Folder.mock(), last: false)
}

