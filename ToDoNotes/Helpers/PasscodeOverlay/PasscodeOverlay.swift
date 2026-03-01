//
//  PasscodeOverlay.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/25/26.
//

import SwiftUI

struct PasscodeOverlayGroup: View {
    @EnvironmentObject private var passcodeManager: PasscodeManager
    @EnvironmentObject private var authService: AuthNetworkService
    @Environment(\.scenePhase) private var scenePhase

    @State private var isRequestingFaceID = false
    @State private var showingForgotAlert = false
    @State private var showOverlay = false

    var body: some View {
        Group {
            if passcodeManager.isLocked && showOverlay {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()

                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    PasscodeFlowView(flow: .unlock, onComplete: {}, onForgot: {
                        showingForgotAlert = true
                    })
                    .environmentObject(passcodeManager)
                }
                .transition(.opacity)
            }
        }
        .allowsHitTesting(passcodeManager.isLocked)
        .animation(.easeInOut(duration: 0.2), value: passcodeManager.isLocked)
        .popView(isPresented: $showingForgotAlert, onTap: {}, onDismiss: {}) {
            forgotAlert
        }
        .onChange(of: passcodeManager.isLocked) { _, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                showOverlay = newValue
            }
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows where window.tag == 1011 {
                    window.isUserInteractionEnabled = newValue
                }
            }
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            triggerFaceIDIfNeeded()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                showOverlay = passcodeManager.isLocked
            }
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows where window.tag == 1011 {
                    window.isUserInteractionEnabled = passcodeManager.isLocked
                }
            }
            triggerFaceIDIfNeeded()
        }
        .onDisappear {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows where window.tag == 1011 {
                    window.isUserInteractionEnabled = false
                }
            }
        }
    }

    private var forgotAlert: some View {
        CustomAlertView(
            title: Texts.Passcode.forgotAlertTitle,
            message: Texts.Passcode.forgotAlertMessage,
            primaryButtonTitle: Texts.Passcode.forgotAlertConfirm,
            primaryAction: {
                showingForgotAlert = false
                handleForgotPassword()
            },
            secondaryButtonTitle: Texts.Passcode.forgotAlertCancel,
            secondaryAction: {
                showingForgotAlert = false
            }
        )
    }

    private func handleForgotPassword() {
        LoadingOverlay.shared.show()
        authService.logoutLocal { _ in
            LoadingOverlay.shared.hide()
            passcodeManager.clearPasscode()
            passcodeManager.shouldShowResetAuth = true
        }
    }

    private func triggerFaceIDIfNeeded() {
        guard passcodeManager.isLocked,
              passcodeManager.isFaceIDEnabled,
              passcodeManager.isBiometricsAvailable,
              !isRequestingFaceID
        else { return }

        isRequestingFaceID = true
        Task {
            _ = await passcodeManager.authenticateWithBiometrics(reason: passcodeManager.biometricReason)
            await MainActor.run {
                isRequestingFaceID = false
            }
        }
    }
}

#Preview {
    PasscodeOverlayGroup()
        .environmentObject(PasscodeManager())
        .environmentObject(AuthNetworkService())
}
