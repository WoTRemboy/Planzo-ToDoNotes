//
//  SettingsProfileRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 08/09/2025.
//

import SwiftUI

struct SettingsProfileRow: View {
    // MARK: - Properties
    
    /// Title displayed in the row.
    private let title: String
    /// Optional image displayed on the left.
    private let imageURL: String?
    /// Optional additional details text displayed under title.
    private let details: String?
    /// Flag to show a chevron (right arrow) icon.
    private let chevron: Bool
    
    // MARK: - Initialization
        
    /// Creates a new instance of `SettingFormRow`.
    /// - Parameters:
    ///   - title: The title text.
    ///   - image: An optional left-side profile image URL.
    ///   - details: An optional details string shown on the right.
    ///   - chevron: Whether to show a chevron icon.
    init(title: String? = nil, image: String? = nil,
         details: String? = nil, chevron: Bool = false) {
        self.title = title ?? "Sign in or Sign up"
        self.imageURL = image
        self.details = details
        self.chevron = chevron
    }
    
    // MARK: - Body
    
    internal var body: some View {
        HStack {
            leftLabel    // Main label with optional image and title
            
            Spacer()
            // Chevron if enabled
            if chevron {
                Image.Settings.chevron
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        
        .padding(.horizontal, 14)
        .frame(height: 56)
        .background(Color.SupportColors.supportButton)
    }
    
    // MARK: - Components
    
    /// Label view displaying the optional image and title on the left.
    private var leftLabel: some View {
        HStack(alignment: .center, spacing: 8) {
            if let imageURL {
                AsyncImage(url: URL(string: imageURL)) { result in
                    result.image?
                        .resizable()
                        .scaledToFit()
                }
                .clipShape(.circle)
                .frame(width: 36, height: 36)
            } else {
                Image.Settings.signIn
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                    .lineLimit(1)
                
                // Optional details text
                if let details {
                    Text(details)
                        .font(.system(size: 13,
                                      weight: .regular))
                        .foregroundStyle(Color.LabelColors.labelSecondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    SettingsProfileRow(
        title: "John Doe",
        image: nil,
        details: "Free Plan",
        chevron: true)
}
