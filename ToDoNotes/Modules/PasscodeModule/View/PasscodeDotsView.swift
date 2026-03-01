//
//  PasscodeDotsView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/25/26.
//

import SwiftUI

struct PasscodeDotsView: View {
    let count: Int
    let filled: Int
    let validationState: PasscodeFlowView.ValidationState
    let shakeTrigger: Int

    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<count, id: \.self) { index in
                let isFilled = index < filled
                Circle()
                    .fill(dotFillColor(isFilled: isFilled))
                    .frame(width: 16, height: 16)
                    .scaleEffect(dotScale(isFilled: isFilled))
                    .overlay(
                        Circle()
                            .stroke(Color.LabelColors.labelSecondary, lineWidth: 1)
                    )
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: filled)
                    .animation(.easeInOut(duration: 0.2), value: validationState)
            }
        }
        .modifier(ShakeEffect(trigger: shakeTrigger))
        .animation(.easeInOut(duration: 0.35), value: shakeTrigger)
    }

    private func dotFillColor(isFilled: Bool) -> Color {
        switch validationState {
        case .success:
            return isFilled ? Color.SupportColors.supportSubscription : .clear
        case .error:
            return isFilled ? Color.LabelColors.labelLogout : .clear
        case .idle:
            return isFilled ? Color.LabelColors.labelPrimary : .clear
        }
    }

    private func dotScale(isFilled: Bool) -> CGFloat {
        switch validationState {
        case .success:
            return isFilled ? 1.35 : 1.0
        case .error:
            return isFilled ? 0.9 : 1.0
        case .idle:
            return isFilled ? 1.15 : 1.0
        }
    }
}

private struct ShakeEffect: GeometryEffect {
    var trigger: Int

    var animatableData: CGFloat {
        get { CGFloat(trigger) }
        set { }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = sin(animatableData * .pi * 2) * 6
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#Preview {
    PasscodeDotsView(
        count: 4,
        filled: 2,
        validationState: .idle,
        shakeTrigger: 0
    )
        .padding()
        .background(Color.BackColors.backDefault)
}
