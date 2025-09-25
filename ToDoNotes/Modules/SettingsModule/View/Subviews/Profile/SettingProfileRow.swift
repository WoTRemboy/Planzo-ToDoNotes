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
    private let isProfile: Bool
    /// Flag indicating whether this is the last row (hides bottom divider).
    private let last: Bool
    
    // MARK: - Initialization
        
    /// Creates a new instance of `SettingsProfileRow`.
    /// - Parameters:
    ///   - title: The title text.
    ///   - image: An optional left-side profile image URL.
    ///   - details: An optional details string shown on the right.
    ///   - chevron: Whether to show a chevron icon.
    init(title: String? = nil, image: String? = nil,
         details: String? = nil, chevron: Bool = false, isProfile: Bool = false, last: Bool = false) {
        self.title = title ?? Texts.Authorization.login
        self.imageURL = image
        self.details = details
        self.chevron = chevron
        self.isProfile = isProfile
        self.last = last
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
            if let imageURL {
                AsyncImage(url: URL(string: imageURL)) { result in
                    if let image = result.image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else {
                        placeholderImage
                    }
                }
                .clipShape(.circle)
                .frame(width: 36, height: 36)
            } else if isProfile {
                EmailInitialCircleView(email: title, type: .small)
                    .frame(width: 36, height: 36)
            }
            textDetailsBlock
        }
    }
    
    private var placeholderImage: some View {
        Image.Settings.signIn
            .resizable()
            .scaledToFit()
    }
    
    private var textDetailsBlock: some View {
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

#Preview {
    SettingsProfileRow(
        title: "John Doe",
        image: nil,
        details: "Free Plan",
        chevron: true)
}
