//
//  FolderFormView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 21/10/2025.
//

import SwiftUI

struct FolderFormView: View {
    
    // MARK: - Properties
    
    /// Title displayed in the row.
    private let title: String
    /// Optional color displayed on the left.
    private let color: Color?
    
    private let hidden: Bool
    private let locked: Bool
    /// Flag indicating whether this is the last row (hides bottom divider).
    private let last: Bool
    
    // MARK: - Initialization
        
    init(title: String, color: Color? = nil,
         hidden: Bool = false, locked: Bool = false,
         last: Bool = false) {
        self.title = title
        self.color = color
        self.hidden = hidden
        self.locked = locked
        self.last = last
    }
    
    // MARK: - Body
    
    internal var body: some View {
        HStack {
            leftLabel
            
            Spacer()
            if hidden {
                Image.Folder.hidden
                    .renderingMode(.template)
                    .foregroundStyle(Color.LabelColors.labelSecondary)
                    .frame(width: 20, height: 20)
            }
            
            if locked {
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
            if let color {
                color
                    .clipShape(.circle)
                    .frame(width: 20, height: 20)
            }
            
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .lineLimit(1)
        }
    }
}

// MARK: - Preview

#Preview {
    FolderFormView(title: "Title",
                   color: .blue,
                   hidden: true,
                   locked: true,
                   last: false)
}

