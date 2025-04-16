//
//  AlertView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/4/25.
//

import SwiftUI

struct CustomAlertView: View {
    private let title: String
    private let message: String?
    private let primaryButtonTitle: String
    private let primaryAction: () -> Void
    private let secondaryButtonTitle: String?
    private let secondaryAction: (() -> Void)?
    
    init(title: String, message: String?, primaryButtonTitle: String, primaryAction: @escaping () -> Void, secondaryButtonTitle: String? = nil, secondaryAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryAction = secondaryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            textBlock
            buttons
        }
        .frame(width: 320)
        
        .background(Color.BackColors.backSecondary)
        .cornerRadius(12)
        .shadow(radius: 10)
        
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var textBlock: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .multilineTextAlignment(.center)
            
            if let message = message {
                Text(message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
    
    private var buttons: some View {
        HStack(spacing: 8) {
            if let secondaryTitle = secondaryButtonTitle,
               let secondaryAction = secondaryAction {
                secondaryButton(title: secondaryTitle, action: secondaryAction)
            }
            primaryButton
        }
        .padding([.bottom, .horizontal], 6)
    }
    
    private var primaryButton: some View {
        Button {
            primaryAction()
        } label: {
            Text(primaryButtonTitle)
                .font(.system(size: 17, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: 50)
                .foregroundColor(Color.LabelColors.labelReversed)
                .background(Color.LabelColors.labelPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    @ViewBuilder
    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.clear)
                .foregroundColor(Color.LabelColors.labelPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.LabelColors.labelDetails, lineWidth: 1)
                )
        }
    }
}

#Preview {
    CustomAlertView(
        title: "Attention",
        message: "Do you really want to delete this task?",
        primaryButtonTitle: "Delete",
        primaryAction: { print("Delete tapped") },
        secondaryButtonTitle: "Cancel",
        secondaryAction: { print("Cancel tapped") }
    )
}
