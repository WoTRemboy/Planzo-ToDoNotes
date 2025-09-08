//
//  AccountDetailsRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 09/09/2025.
//

import SwiftUI

struct AccountDetailsRow: View {
    // MARK: - Properties
    
    /// Title displayed in the row.
    private let title: String
    /// Optional additional details text displayed under title.
    private let details: String?
    /// Flag to show a chevron (right arrow) icon.
    private let chevron: Bool
    /// Flag indicating whether this is the last row (hides bottom divider).
    private let last: Bool
    
    
    // MARK: - Initialization
        
    /// Creates a new instance of `AccountDetailsRow`.
    /// - Parameters:
    ///   - title: The title text.
    ///   - details: An optional details string shown on the right.
    ///   - chevron: Whether to show a chevron icon.
    init(title: String, details: String? = nil,
         chevron: Bool = false, last: Bool = false) {
        self.title = title
        self.details = details
        self.chevron = chevron
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
    AccountDetailsRow(
        title: "Nickname",
        details: "John Doe",
        chevron: true)
}
