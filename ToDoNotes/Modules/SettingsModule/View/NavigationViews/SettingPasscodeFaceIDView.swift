//
//  SettingPasscodeFaceIDView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/25/26.
//

import SwiftUI
import UIKit

struct SettingPasscodeFaceIDView: View {
    @EnvironmentObject private var passcodeManager: PasscodeManager
    @EnvironmentObject private var authService: AuthNetworkService
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    @State private var showingCreateFlow = false
    @State private var showingChangeFlow = false
    @State private var showingDisableFlow = false
    @State private var isRequestingFaceId = false
    @State private var showingForgotAlert = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    passcodeToggle
                    if passcodeManager.isPasscodeEnabled {
                        faceIdToggle
                        descriptionText
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .frame(width: contentWidth(for: proxy))
                .frame(maxWidth: .infinity)
            }
        }
        .customNavBarItems(
            title: passcodeManager.settingsTitle,
            showBackButton: true,
            position: .center
        )
        .sheet(isPresented: $showingCreateFlow) {
            PasscodeFlowView(flow: .create, onComplete: {
                passcodeManager.refreshBiometricsAvailability()
            })
            .environmentObject(passcodeManager)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingChangeFlow) {
            PasscodeFlowView(flow: .change, onForgot: {
                dismissPasscodeSheetAndShowAlert()
            })
                .environmentObject(passcodeManager)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingDisableFlow) {
            PasscodeFlowView(flow: .disable, onComplete: {
                passcodeManager.clearPasscode()
            }, onForgot: {
                dismissPasscodeSheetAndShowAlert()
            })
            .environmentObject(passcodeManager)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .popView(isPresented: $showingForgotAlert, onTap: {}, onDismiss: {}) {
            forgotAlert
        }
        .onAppear {
            passcodeManager.refreshBiometricsAvailability()
        }
    }

    private func contentWidth(for proxy: GeometryProxy) -> CGFloat? {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return nil }
        let isPortrait = proxy.size.height >= proxy.size.width
        return proxy.size.width * (isPortrait ? 0.7 : 0.5)
    }

    private var passcodeToggle: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .trailing) {
                SettingFormRow(
                    title: Texts.Passcode.passcodeTitle,
                    last: !passcodeManager.isPasscodeEnabled)
                Toggle(isOn: Binding(
                    get: { passcodeManager.isPasscodeEnabled },
                    set: { newValue in
                        if newValue {
                            showingCreateFlow = true
                        } else {
                            showingDisableFlow = true
                        }
                    }
                )) {}
                    .fixedSize()
                    .tint(Color.ToggleColors.main)
                    .padding(.trailing, 14)
                    .scaleEffect(toggleScale)
            }
            
            if passcodeManager.isPasscodeEnabled {
                changePasscodeButton
            }
        }
        .modifier(SystemRowCornerModifier())
    }

    private var toggleScale: CGFloat {
        if #available(iOS 26.0, *) {
            return 1
        }
        return 0.8
    }
    
    private var changePasscodeButton: some View {
        Button {
            showingChangeFlow = true
        } label: {
            SettingFormRow(
                title: Texts.Passcode.changeTitle,
                chevron: true,
                last: true
            )
        }
    }

    private var faceIdToggle: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .trailing) {
                SettingFormRow(title: passcodeManager.biometricTitle, last: true)
                Toggle(isOn: Binding(
                    get: { passcodeManager.isFaceIDEnabled },
                    set: { newValue in
                        if !newValue {
                            passcodeManager.isFaceIDEnabled = false
                            return
                        }

                        guard !isRequestingFaceId else { return }
                        isRequestingFaceId = true
                        Task {
                            let success = await passcodeManager.authenticateWithBiometrics(reason: passcodeManager.biometricReason, allowWhenDisabled: true)
                            await MainActor.run {
                                passcodeManager.isFaceIDEnabled = success
                                isRequestingFaceId = false
                            }
                        }
                    }
                )) {}
                .fixedSize()
                .tint(Color.ToggleColors.main)
                .padding(.trailing, 14)
                .scaleEffect(toggleScale)
                .disabled(!passcodeManager.isBiometricsAvailable || isRequestingFaceId)
            }
            .background(Color.SupportColors.supportButton)
        }
        .modifier(SystemRowCornerModifier())
    }

    private var descriptionText: some View {
        Text(passcodeManager.descriptionText)
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
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

    private func dismissPasscodeSheetAndShowAlert() {
        showingCreateFlow = false
        showingChangeFlow = false
        showingDisableFlow = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showingForgotAlert = true
        }
    }

    private func handleForgotPassword() {
        settingsViewModel.handleLogout(authService: authService)
        passcodeManager.clearPasscode()
        passcodeManager.shouldShowResetAuth = true
    }
}

#Preview {
    SettingPasscodeFaceIDView()
        .environmentObject(PasscodeManager())
        .environmentObject(AuthNetworkService())
        .environmentObject(SettingsViewModel(notificationsEnabled: true))
}
