//
//  PasscodeResetAuthorizationView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 2/25/26.
//

import SwiftUI

struct PasscodeResetAuthorizationView: View {
    @EnvironmentObject private var authService: AuthNetworkService
    @EnvironmentObject private var passcodeManager: PasscodeManager
    @Environment(\.dismiss) private var dismiss

    @StateObject private var appleAuthService: AppleAuthService
    @StateObject private var googleAuthService: GoogleAuthService

    @State private var isAuthorizing = false
    @State private var showingErrorAlert = false

    private let onboardingStep = OnboardingStep.stepsSetup().first

    init(networkService: AuthNetworkService) {
        _appleAuthService = StateObject(wrappedValue: AppleAuthService(networkService: networkService))
        _googleAuthService = StateObject(wrappedValue: GoogleAuthService(networkService: networkService))
    }

    var body: some View {
        ZStack {
            Color.BackColors.backDefault
                .ignoresSafeArea()

            VStack(spacing: 0) {
                onboardingContent
                authorizationView
                termsPolicyLabel
                    .padding(.top, 16)
                    .padding(.horizontal)
                Spacer()
            }

            if isAuthorizing {
                loadingOverlay
            }
        }
        .popView(isPresented: $showingErrorAlert, onTap: {}, onDismiss: {}) {
            errorAlert
        }
        .onAppear {
            if authService.isAuthorized {
                dismiss()
            }
        }
    }

    private var onboardingContent: some View {
        VStack(spacing: 0) {
            if let onboardingStep {
                onboardingStep.image
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(.horizontal)
                    .padding(.top, 8)

                Text(Texts.Passcode.resetAuthPrompt)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .frame(width: 270)
                    .padding(.top, 24)
            }
        }
    }

    private var authorizationView: some View {
        VStack(spacing: 16) {
            LoginButtonView(type: .apple) {
                handleAppleSignIn()
            }
            LoginButtonView(type: .google) {
                handleGoogleSignIn()
            }
        }
        .padding(.top, 24)
        .padding(.horizontal)
    }

    private var termsPolicyLabel: some View {
        if let attributedText = try? AttributedString(markdown: Texts.OnboardingPage.markdownTerms) {
            return Text(attributedText)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundStyle(Color.LabelColors.labelDetails)
        } else {
            return Text(Texts.OnboardingPage.markdownTermsError)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundStyle(Color.LabelColors.labelDetails)
        }
    }

    private var errorAlert: some View {
        CustomAlertView(
            title: Texts.Authorization.Error.authorizationFailed,
            message: Texts.Authorization.Error.retryLater,
            primaryButtonTitle: Texts.Settings.ok,
            primaryAction: {
                showingErrorAlert = false
            }
        )
    }

    private var loadingOverlay: some View {
        Color.black.opacity(0.25)
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.backSheet)
                        .frame(width: 60, height: 60)

                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.6)
                }
            )
            .transition(.opacity)
    }

    private func handleGoogleSignIn() {
        guard let topVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) })
            .first?.rootViewController else {
            return
        }

        isAuthorizing = true
        googleAuthService.signInWithGoogle(presentingViewController: topVC) { result in
            DispatchQueue.main.async {
                isAuthorizing = false
                switch result {
                case .success:
                    dismiss()
                case .failure:
                    showingErrorAlert = true
                }
            }
        }
    }

    private func handleAppleSignIn() {
        isAuthorizing = true
        appleAuthService.onBackendAuthResult = { result in
            DispatchQueue.main.async {
                isAuthorizing = false
                switch result {
                case .success:
                    dismiss()
                case .failure:
                    showingErrorAlert = true
                }
            }
        }
        appleAuthService.onAuthError = { _ in
            DispatchQueue.main.async {
                isAuthorizing = false
                showingErrorAlert = true
            }
        }
        appleAuthService.startAppleSignIn()
    }
}

#Preview {
    PasscodeResetAuthorizationView(networkService: AuthNetworkService())
        .environmentObject(AuthNetworkService())
        .environmentObject(PasscodeManager())
}
