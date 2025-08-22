//  SelectorView.swift
//  ToDoNotes
//  Universal configurable selector sheet for settings

import SwiftUI

/// Universal component for selecting one option from a list with confirmation and cancellation buttons.
struct SelectorView<Option: Hashable>: View {
    /// Title of the selection window
    private let title: String
    /// Optional label formatter closure
    private let label: ((Option) -> String)?
    
    /// List of all possible options
    private let options: [Option]
    /// Currently selected option (binding)
    @Binding private var selected: Option
    
    /// Action on cancel
    private let onCancel: () -> Void
    /// Action on accept
    private let onAccept: (Option) -> Void
    
    /// Cancel button title
    private let cancelTitle: String
    /// Accept button title
    private let acceptTitle: String
    
    /// Colors and styling (optional, can be extended)
    private var background: Color = Color.BackColors.backSecondary
    private var cornerRadius: CGFloat = 12
    
    init(
        title: String,
        label: ((Option) -> String)? = nil,
        options: [Option],
        selected: Binding<Option>,
        onCancel: @escaping () -> Void,
        onAccept: @escaping (Option) -> Void,
        cancelTitle: String,
        acceptTitle: String,
        background: Color = Color.BackColors.backSecondary,
        cornerRadius: CGFloat = 12,
    ) {
        self.title = title
        self.label = label
        self.options = options
        self._selected = selected
        self.onCancel = onCancel
        self.onAccept = onAccept
        self.cancelTitle = cancelTitle
        self.acceptTitle = acceptTitle
        self.background = background
        self.cornerRadius = cornerRadius
    }
    
    internal var body: some View {
        VStack(spacing: 20) {
            titleLabel
            optionsList
            
            HStack(spacing: 4) {
                cancelButton
                acceptButton
            }
            .padding([.horizontal, .bottom], 6)
        }
        .frame(width: 320)
        .background(background)
        .cornerRadius(cornerRadius)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var titleLabel: some View {
        Text(title)
            .font(.system(size: 17, weight: .semibold))
            .padding(.top, 12)
    }
    
    private var optionsList: some View {
        VStack(spacing: 16) {
            ForEach(options, id: \.self) { option in
                let isSelected = selected == option
                Button {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        selected = option
                    }
                } label: {
                    HStack {
                        Text(label?(option) ?? String(describing: option))
                            .font(.system(size: 17, weight: .regular))
                        Spacer()
                        
                        (isSelected ? Image.Selector.selected :
                            Image.Selector.unselected)
                        .resizable()
                        .frame(width: 20, height: 20)
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal, 16)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var cancelButton: some View {
        Button(action: onCancel) {
            ZStack {
                Color.clear
                Text(cancelTitle)
                    .font(.system(size: 17, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.LabelColors.labelPrimary)
            }
            .clipShape(.rect(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.LabelColors.labelDetails, lineWidth: 1)
            )
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
    
    private var acceptButton: some View {
        Button {
            onAccept(selected)
        } label: {
            ZStack {
                Color.LabelColors.labelPrimary
                Text(acceptTitle)
                    .font(.system(size: 17, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.LabelColors.labelReversed)
            }
            .clipShape(.rect(cornerRadius: 10))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: Theme = .systemDefault
        
        var body: some View {
            SelectorView<Theme>(
                title: "Appearance",
                label: { $0.name },
                options: Theme.allCases,
                selected: $selected,
                onCancel: {},
                onAccept: { (_: Theme) in },
                cancelTitle: "Cancel",
                acceptTitle: "Accept",
            )
        }
    }
    
    return PreviewWrapper()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}

