//
//  PasscodeFlowView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/25/26.
//

import SwiftUI
import UIKit

struct PasscodeFlowView: View {
    enum Flow {
        case unlock
        case create
        case change
        case reset
        case disable
    }

    @EnvironmentObject private var passcodeManager: PasscodeManager
    @Environment(\.dismiss) private var dismiss

    let flow: Flow
    let onComplete: (() -> Void)?
    let onForgot: (() -> Void)?

    @State private var step: Step
    @State private var input: String = ""
    @State private var firstEntry: String = ""
    @State private var errorMessage: String? = nil
    @State private var validationState: ValidationState = .idle
    @State private var shakeTrigger: Int = 0

    private let passcodeLength = 4

    init(flow: Flow, onComplete: (() -> Void)? = nil, onForgot: (() -> Void)? = nil) {
        self.flow = flow
        self.onComplete = onComplete
        self.onForgot = onForgot
        self._step = State(initialValue: Step.initial(for: flow))
    }

    var body: some View {
        VStack(spacing: 24) {
            navBar
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.LabelColors.labelPrimary)

                if let subtitle = step.subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.LabelColors.labelSecondary)
                }

            }
            .multilineTextAlignment(.center)

            PasscodeDotsView(
                count: passcodeLength,
                filled: input.count,
                validationState: validationState,
                shakeTrigger: shakeTrigger
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelLogout)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            PasscodeKeypadView(
                onDigit: handleDigit,
                onDelete: handleDelete,
                onForgot: onForgot,
                onFaceID: {
                    Task {
                        _ = await passcodeManager.authenticateWithBiometrics(reason: passcodeManager.biometricReason)
                        if !passcodeManager.isLocked {
                            onComplete?()
                        }
                    }
                },
                showsForgot: step.showsForgot,
                showsFaceID: step.showsFaceID && passcodeManager.isFaceIDEnabled && passcodeManager.isBiometricsAvailable,
                biometricIconName: passcodeManager.biometricIconName
            )
            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal, 28)
        .onAppear {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            if step.shouldTriggerBiometrics {
                Task {
                    _ = await passcodeManager.authenticateWithBiometrics(reason: passcodeManager.biometricReason)
                    if !passcodeManager.isLocked {
                        animateSuccess {
                            onComplete?()
                        }
                    }
                }
            }
        }
    }

    private var navBar: some View {
        HStack {
            if step.showsClose {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.LabelColors.labelPrimary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.SupportColors.supportButton))
                }
            } else {
                Spacer()
                    .frame(width: 32, height: 32)
            }

            Spacer()

            if step.showsConfirm {
                let canConfirm = input.count == passcodeLength
                Button {
                    finalizeFlow()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(canConfirm ? Color.LabelColors.labelPrimary : Color.LabelColors.labelSecondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.SupportColors.supportButton))
                }
                .disabled(!canConfirm)
            } else {
                Spacer()
                    .frame(width: 32, height: 32)
            }
        }
    }

    private func handleDigit(_ digit: String) {
        guard input.count < passcodeLength else { return }
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()

        input.append(digit)

        if input.count == passcodeLength {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                handleCompleteInput()
            }
        }
    }

    private func handleDelete() {
        guard !input.isEmpty else { return }
        input.removeLast()
    }

    private func handleCompleteInput() {
        switch step {
        case .unlock:
            if passcodeManager.unlock(with: input) {
                animateSuccess {
                    finalizeFlow()
                }
            } else {
                showError(Texts.Passcode.errorIncorrect)
            }
        case .create:
            firstEntry = input
            input = ""
            step = .confirm
        case .confirm:
            if input == firstEntry {
                if passcodeManager.setNewPasscode(input) {
                    showPasscodeSetToast()
                    animateSuccess {
                        finalizeFlow()
                    }
                } else {
                    showError(Texts.Passcode.errorGeneric)
                }
            } else {
                showError(Texts.Passcode.errorMismatch)
            }
        case .verifyCurrent:
            if passcodeManager.unlock(with: input) {
                if flow == .disable {
                    animateSuccess {
                        finalizeFlow()
                    }
                } else {
                    input = ""
                    step = .changeNew
                }
            } else {
                showError(Texts.Passcode.errorIncorrect)
            }
        case .changeNew:
            firstEntry = input
            input = ""
            step = .changeConfirm
        case .changeConfirm:
            if input == firstEntry {
                if passcodeManager.updatePasscode(input) {
                    showPasscodeSetToast()
                    animateSuccess {
                        finalizeFlow()
                    }
                } else {
                    showError(Texts.Passcode.errorGeneric)
                }
            } else {
                showError(Texts.Passcode.errorMismatch)
            }
        case .reset:
            firstEntry = input
            input = ""
            step = .resetConfirm
        case .resetConfirm:
            if input == firstEntry {
                if passcodeManager.updatePasscode(input) {
                    showPasscodeSetToast()
                    animateSuccess {
                        finalizeFlow()
                    }
                } else {
                    showError(Texts.Passcode.errorGeneric)
                }
            } else {
                showError(Texts.Passcode.errorMismatch)
            }
        }
    }

    private func finalizeFlow() {
        onComplete?()
        dismiss()
    }

    private func showError(_ message: String) {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)

        withAnimation(.easeInOut(duration: 0.2)) {
            validationState = .error
            shakeTrigger += 1
            errorMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            input = ""
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.2)) {
                validationState = .idle
                errorMessage = nil
            }
        }
    }

    private func animateSuccess(completion: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.2)) {
            validationState = .success
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion()
        }
    }

    private func showPasscodeSetToast() {
        Toast.shared.present(title: Texts.Toasts.passcodeSet)
    }
}

extension PasscodeFlowView {
    enum ValidationState {
        case idle
        case success
        case error
    }

    enum Step {
        case unlock
        case create
        case confirm
        case verifyCurrent
        case changeNew
        case changeConfirm
        case reset
        case resetConfirm

        static func initial(for flow: Flow) -> Step {
            switch flow {
            case .unlock:
                return .unlock
            case .create:
                return .create
            case .change:
                return .verifyCurrent
            case .reset:
                return .reset
            case .disable:
                return .verifyCurrent
            }
        }

        var title: String {
            switch self {
            case .unlock:
                return Texts.Passcode.enterTitle
            case .create:
                return Texts.Passcode.createTitle
            case .confirm:
                return Texts.Passcode.confirmTitle
            case .verifyCurrent:
                return Texts.Passcode.verifyCurrentTitle
            case .changeNew:
                return Texts.Passcode.newTitle
            case .changeConfirm:
                return Texts.Passcode.confirmTitle
            case .reset:
                return Texts.Passcode.resetTitle
            case .resetConfirm:
                return Texts.Passcode.confirmTitle
            }
        }

        var subtitle: String? {
            switch self {
            case .unlock:
                return nil
            case .create:
                return Texts.Passcode.createSubtitle
            case .confirm:
                return Texts.Passcode.confirmSubtitle
            case .verifyCurrent:
                return Texts.Passcode.verifyCurrentSubtitle
            case .changeNew:
                return Texts.Passcode.newSubtitle
            case .changeConfirm:
                return Texts.Passcode.confirmSubtitle
            case .reset:
                return Texts.Passcode.resetSubtitle
            case .resetConfirm:
                return Texts.Passcode.confirmSubtitle
            }
        }

        var showsForgot: Bool {
            switch self {
            case .unlock, .verifyCurrent:
                return true
            default:
                return false
            }
        }

        var showsFaceID: Bool {
            self == .unlock
        }

        var showsClose: Bool {
            switch self {
            case .unlock:
                return false
            default:
                return true
            }
        }

        var showsConfirm: Bool {
            switch self {
            case .confirm, .changeConfirm, .resetConfirm:
                return true
            default:
                return false
            }
        }

        var shouldTriggerBiometrics: Bool {
            self == .unlock
        }
    }
}

#Preview {
    PasscodeFlowView(flow: .unlock)
        .environmentObject(PasscodeManager())
        .background(Color.BackColors.backDefault)
}
