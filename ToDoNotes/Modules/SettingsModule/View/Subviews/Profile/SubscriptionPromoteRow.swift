//
//  SubscriptionPromoteRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 09/09/2025.
//

import SwiftUI

struct SubscriptionPromoteRow: View {
    internal var body: some View {
        HStack {
            leftLabel
            
            Spacer()
            Image.Settings.chevron
                .resizable()
                .frame(width: 20, height: 20)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 56)
        .background(Color.SupportColors.supportButton)
    }
    
    // MARK: - Components
    
    /// Label view displaying the optional image and title on the left.
    private var leftLabel: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleView
            detailsLabel
        }
        .padding(.vertical, 10)
    }
    
    private var titleView: some View {
        HStack(alignment: .center, spacing: 4) {
            Text("Upgrade to")
            proCapsuleView
            Text("or start Free Trial")
        }
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(Color.LabelColors.labelPrimary)
        .lineLimit(1)
    }
    
    private var proCapsuleView: some View {
        Text("PRO")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelBlack)
        
            .padding(.vertical, 2)
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.LabelColors.labelSubscription)
            }
    }
    
    private var detailsLabel: some View {
        Text("Share tasks, customize your calendar, track progress, and more.")
            .font(.system(size: 13,
                          weight: .regular))
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .multilineTextAlignment(.leading)
    }
}

#Preview {
    SubscriptionPromoteRow()
}
