//
//  OnboardingScreenView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI
import SwiftUIPager
import TipKit
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.opening", category: "OnboardingScreenView")

/// View displaying the onboarding process or the main `RootView` if onboarding is complete.
struct OnboardingScreenView: View {
    
    // MARK: - Environment
    
    /// Detects the current system color scheme.
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Properties
    
    /// View model controlling the onboarding state.
    @StateObject private var viewModel = OnboardingViewModel()
    
    /// Current page tracker for the pager.
    @StateObject private var page: Page = .first()
    
    /// Apple authentication service.
    @StateObject private var appleAuthService: AppleAuthService
    
    /// Google authentication service.
    @StateObject private var googleAuthService: GoogleAuthService
    
    init(networkService: AuthNetworkService) {
        _appleAuthService = StateObject(wrappedValue: AppleAuthService(networkService: networkService))
        
        let googleClientID = ProcessInfo.processInfo.environment["GOOGLE_CLIENT_ID"] ?? String()
        _googleAuthService = StateObject(wrappedValue: GoogleAuthService(clientID: googleClientID, networkService: networkService))
    }
    
    // MARK: - Body
    
    internal var body: some View {
        if viewModel.skipOnboarding {
            // If onboarding is completed, shows the main content
            RootView {
                ContentView()
                    .environmentObject(TabRouter())
                    .task {
                        do {
                            try Tips.configure([
                                .datastoreLocation(.applicationDefault)])
                            logger.debug("Tips configured successfully.")
                        } catch {
                            logger.error("Tips configuration failed: \(error.localizedDescription).")
                        }
                    }
            }
        } else {
            // Displays onboarding flow
            VStack(spacing: 0) {
                content
                progressCircles
                selectPageButtons
                
                if viewModel.isLastPage(current: page.index) {
                    signInButtons
                    termsPolicyLabel
                        .padding([.top, .horizontal])
                        .padding(.bottom, hasNotch() ? 4 : 0)
                } else {
                    skipButton
                }
                
            }
            .padding(.vertical)
            
            .onAppear {
                appleAuthService.onBackendAuthResult = { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            viewModel.transferToMainPage()
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            viewModel.alertError = IdentifiableError(wrapped: error)
                        }
                    }
                }
            }
            .alert(item: $viewModel.alertError) { error in
                Alert(title: Text(Texts.Authorization.Error.authorizationFailed),
                      message: Text(error.localizedDescription),
                      dismissButton: .default(Text(Texts.Settings.ok)))
            }
        }
    }
    
    // MARK: - Pager Content
    
    /// Displays onboarding pages with images and titles inside a pager.
    private var content: some View {
        Pager(page: page,
              data: viewModel.pages,
              id: \.self) { index in
            VStack(spacing: 0) {
                viewModel.steps[index].image
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(.horizontal)
                
                Text(viewModel.steps[index].name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .frame(width: index == 1 ? 350 : 270)
                    .padding(.top, hasNotch() ? 24 : 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .tag(index)
        }
              .interactive(scale: 0.8)
              .itemSpacing(10)
              .itemAspectRatio(1.0)
              .expandPageToEdges()
        
              .swipeInteractionArea(.allAvailable)
              .multiplePagination()
              .horizontal()
    }
    
    // MARK: - Progress Circles
    
    /// Displays the progress indicator for the onboarding steps.
    private var progressCircles: some View {
        HStack {
            ForEach(viewModel.pages, id: \.self) { step in
                if step == page.index {
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(Color.LabelColors.labelPrimary)
                        .transition(.scale)
                } else {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundStyle(Color.labelDisable)
                        .transition(.scale)
                }
            }
        }
        .padding(.top)
    }
    
    // MARK: - Navigation Buttons
    
    /// Displays the button that either advances the pager or finishes onboarding.
    private var selectPageButtons: some View {
        Group {
            if !viewModel.isLastPage(current: page.index) {
                nextPageButton
                    .transition(.blurReplace)
            } else {
                nextPageButton
                    .transition(.blurReplace)
            }
        }
    }
    
    // MARK: - Action Button
    
    /// Button for advancing to the next step or completing onboarding.
    private var nextPageButton: some View {
        Button {
            if !viewModel.isLastPage(current: page.index) {
                withAnimation {
                    page.update(.next)
                }
            } else {
                viewModel.transferToMainPage()
            }
        } label: {
            Text(!viewModel.isLastPage(current: page.index) ? Texts.OnboardingPage.next : Texts.Authorization.withoutAuth)
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
                .foregroundColor(Color.LabelColors.labelReversed)
                .background(Color.LabelColors.labelPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var signInButtons: some View {
        VStack(spacing: 16) {
            signWithAppleButton
            signWithGoogleButton
        }
        .transition(.blurReplace)
        .padding([.top, .horizontal])
    }
    
    // MARK: - Sign with Apple Button
    
    /// Button for signing in with Apple using AppleAuthService.
    private var signWithAppleButton: some View {
        LoginButtonView(type: .apple) {
            appleAuthService.startAppleSignIn()
        }
    }
    
    // MARK: - Sign with Google Button
    
    /// Button for signing in with Google using GoogleAuthService.
    private var signWithGoogleButton: some View {
        LoginButtonView(type: .google) {
            viewModel.handleGoogleSignIn(googleAuthService: googleAuthService)
        }
    }
    
    // MARK: - Skip Button
    
    /// Button allowing users to skip to the last onboarding step.
    private var skipButton: some View {
        Text(Texts.OnboardingPage.skip)
            .font(.system(size: 14))
            .fontWeight(.medium)
            .foregroundStyle(Color.LabelColors.labelPrimary)
        
            .padding(.top)
            .padding(.bottom, hasNotch() ? 20 : 16)
        
            .onTapGesture {
                if !viewModel.isLastPage(current: page.index) {
                    withAnimation {
                        page.update(.moveToLast)
                    }
                }
            }
            .animation(.easeInOut, value: page.index)
    }
    
    // MARK: - Terms and Policy
    
    /// Displays the terms of service and privacy policy acknowledgment text.
    private var termsPolicyLabel: some View {
        if let attributedText = try? AttributedString(markdown: Texts.OnboardingPage.markdownTerms) {
            logger.debug("Attributed terms string successfully created from markdown.")
            return Text(attributedText)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundStyle(Color.LabelColors.labelDetails)
            
        } else {
            logger.error("Attributed terms string creation failed from markdown.")
            return Text(Texts.OnboardingPage.markdownTermsError)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundStyle(Color.LabelColors.labelDetails)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingScreenView(networkService: AuthNetworkService())
        .environmentObject(OnboardingViewModel())
}
