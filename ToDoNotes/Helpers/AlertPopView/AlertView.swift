//
//  AlertView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/4/25.
//

import SwiftUI

/// A customizable alert view with a title, optional message, and up to two buttons.
struct CustomAlertView: View {
    
    // MARK: - Properties
    
    /// The title text displayed at the top of the alert.
    private let title: String
    /// An optional message text displayed below the title.
    private let message: String?
    /// The title for the primary button.
    private let primaryButtonTitle: String
    /// The action to perform when the primary button is tapped.
    private let primaryAction: () -> Void
    /// The optional title for the secondary button.
    private let secondaryButtonTitle: String?
    /// The optional action to perform when the secondary button is tapped.
    private let secondaryAction: (() -> Void)?
    
    // MARK: - Initializer
    
    /// Creates a new `CustomAlertView`.
    /// - Parameters:
    ///   - title: The alert's title text.
    ///   - message: An optional message displayed below the title.
    ///   - primaryButtonTitle: The title for the primary button.
    ///   - primaryAction: The closure to execute when the primary button is tapped.
    ///   - secondaryButtonTitle: An optional title for the secondary button.
    ///   - secondaryAction: An optional closure to execute when the secondary button is tapped.
    init(
        title: String,
        message: String?,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void,
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryAction = secondaryAction
    }
    
    // MARK: - Body
    
    /// The main view body of the alert, containing the text and buttons.
    internal var body: some View {
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
    
    // MARK: - Components
    
    /// Builds the text block containing the title and optional message.
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
    
    /// Builds the horizontal stack of buttons, including secondary (if any) and primary buttons.
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
    
    /// Builds the primary button with its action and styling.
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
    
    /// Builds the secondary button with its action and styling.
    /// - Parameters:
    ///   - title: The title text for the secondary button.
    ///   - action: The closure to execute when the secondary button is tapped.
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

// MARK: - Preview

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
