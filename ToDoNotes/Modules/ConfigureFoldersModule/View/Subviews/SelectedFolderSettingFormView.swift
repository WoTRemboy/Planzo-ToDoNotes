//
//  SelectedFolderSettingFormView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 24/10/2025.
//

import SwiftUI

struct SelectedFolderSettingFormView: View {
    @State private var folder: Folder = .newFolder
    private let type: FolderConfig
    /// Flag indicating whether this is the last row (hides bottom divider).
    private let last: Bool
    
    // MARK: - Initialization
    
    init (folder: Folder?, type: FolderConfig, last: Bool = false) {
        if let folder {
            self.folder = folder
        }
        self.type = type
        self.last = last
    }
    
    // MARK: - Body
    
    internal var body: some View {
        HStack {
            leftLabel
            
            Spacer()
            switch type {
            case .name:
                nameDetails
            case .color:
                colorDetails
            case .lock:
                lockedToggle
            case .visibility:
                visibilityToggle
            }
            // Chevron if enabled
            if type.chevron {
                Image.Settings.chevron
                    .resizable()
                    .frame(width: 20, height: 20)
            }
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
        VStack(alignment: .leading, spacing: 2) {
            Text(type.name)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .lineLimit(1)
            
            if let details = type.description {
                Text(details)
                    .font(.system(size: 13,
                                  weight: .regular))
                    .lineLimit(1)
                    .foregroundStyle(Color.LabelColors.labelSecondary)
            }
        }
    }
    
    private var nameDetails: some View {
        Text(folder.localizedName)
            .font(.system(size: 13,
                          weight: .regular))
            .lineLimit(1)
            .foregroundStyle(Color.LabelColors.labelSecondary)
    }
    
    private var colorDetails: some View {
        color
            .clipShape(.circle)
            .frame(width: 20, height: 20)
    }
    
    private var lockedToggle: some View {
        Toggle(isOn: $folder.locked) {}
            .fixedSize()
            .background(Color.SupportColors.supportButton)
            .tint(Color.ToggleColors.main)
            .scaleEffect(0.8)
    }
    
    private var visibilityToggle: some View {
        Toggle(isOn: $folder.visible) {}
            .fixedSize()
            .background(Color.SupportColors.supportButton)
            .tint(Color.ToggleColors.main)
            .scaleEffect(0.8)
    }
    
    private var color: Color {
        if folder.system {
            return Color.FolderColors.all
        }
        return folder.color.rgbToColor()
    }
}

#Preview {
    SelectedFolderSettingFormView(folder: .mock(), type: .color)
}
