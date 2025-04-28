//
//  SettingFormRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

/// A reusable row view for settings screens, supporting an icon, title, optional details, and optional right-side icons (chevron or checkmark).
struct SettingFormRow: View {
    
    // MARK: - Properties
    
    /// Title displayed in the row.
    private let title: String
    /// Optional image displayed on the left.
    private let image: Image?
    /// Optional additional details text displayed before chevron.
    private let details: String?
    /// Flag to show a chevron (right arrow) icon.
    private let chevron: Bool
    /// Flag to show a checkmark icon.
    private let check: Bool
    /// Flag indicating whether this is the last row (hides bottom divider).
    private let last: Bool
    
    // MARK: - Initialization
        
    /// Creates a new instance of `SettingFormRow`.
    /// - Parameters:
    ///   - title: The title text.
    ///   - image: An optional left-side image.
    ///   - details: An optional details string shown on the right.
    ///   - chevron: Whether to show a chevron icon.
    ///   - check: Whether to show a checkmark icon.
    ///   - last: Whether this is the last item in the section.
    init(title: String, image: Image? = nil,
         details: String? = nil, chevron: Bool = false,
         check: Bool = false, last: Bool = false) {
        self.title = title
        self.image = image
        self.details = details
        self.chevron = chevron
        self.check = check
        self.last = last
    }
    
    // MARK: - Body
    
    internal var body: some View {
        HStack {
            leftLabel    // Main label with optional image and title
            
            Spacer()
            // Optional details text
            if let details {
                Text(details)
                    .font(.system(size: 13,
                                  weight: .regular))
                    .lineLimit(1)
                    .foregroundStyle(Color.LabelColors.labelSecondary)
            }
            // Chevron if enabled
            if chevron {
                Image.Settings.chevron
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            // Checkmark if enabled
            if check {
                Image.Settings.check
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.accentColor)
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
        HStack(alignment: .center, spacing: 8) {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 5))
                    .frame(width: 22, height: 22)
            }
            
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingFormRow(title: "Title",
                   image: Image.Settings.appearance,
                   details: "hi",
                   chevron: true,
                   check: true,
                   last: false)
}
