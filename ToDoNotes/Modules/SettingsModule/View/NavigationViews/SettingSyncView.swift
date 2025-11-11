//
//  SettingSyncView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 11/11/2025.
//

import SwiftUI
import OSLog

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.settings", category: "SettingSyncView")

struct SettingSyncView: View {
    
    @EnvironmentObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var authService: AuthNetworkService
    
    /// Apple authentication service.
    @ObservedObject private var appleAuthService: AppleAuthService
    /// Google authentication service.
    @ObservedObject private var googleAuthService: GoogleAuthService
        
    init(appleAuthService: AppleAuthService, googleAuthService: GoogleAuthService) {
        self.appleAuthService = appleAuthService
        self.googleAuthService = googleAuthService
    }
    
    internal var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                if authService.isAuthorized {
                    syncActiveView
                    SettingSyncFAQView()
                    userSupportLabel
                        .multilineTextAlignment(.center)
                        .accentColor(Color.SupportColors.supportSubscription)
                } else {
                    syncDisabledView
                    loginView
                    termsPolicyLabel
                        .multilineTextAlignment(.center)
                        .accentColor(Color.SupportColors.supportSubscription)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: authService.currentUser)
            .padding()
        }
        .customNavBarItems(
            title: Texts.Settings.Sync.title,
            showBackButton: true)
    }
    
    private var syncDisabledView: some View {
        HStack {
            Image.Settings.sync
                .resizable()
                .frame(width: 22, height: 22)
            
            Text(Texts.Settings.Sync.disabled)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        
        .background(Color.SupportColors.supportButton)
        .clipShape(.rect(cornerRadius: 10))
    }
    
    private var syncActiveView: some View {
        VStack(alignment: .leading) {
            HStack {
                Image.Settings.sync
                    .resizable()
                    .frame(width: 22, height: 22)
                
                Text(Texts.Settings.Sync.title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                
                Spacer()
                Button {
                    // Sync Button Action
                } label: {
                    Text(Texts.Settings.Sync.update)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.LabelColors.labelReversed)
                    
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Color.LabelColors.labelPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
            }
            Text("\(Texts.Settings.Sync.lastSync): \(viewModel.lastSyncString(dateString: authService.currentUser?.lastSyncAt))")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelSecondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        
        .background(Color.SupportColors.supportButton)
        .clipShape(.rect(cornerRadius: 10))
    }
    
    private var loginView: some View {
        VStack(spacing: 16) {
            Text(Texts.Settings.Sync.login)
                .font(.system(size: 15, weight: .regular))
                .padding(.horizontal)
            
            appleLoginButton
            googleLoginButton
        }
        .padding(.vertical)
    }
    
    private var appleLoginButton: some View {
        LoginButtonView(type: .apple) {
            viewModel.handleAppleSignIn(appleAuthService: appleAuthService)
        }
    }
    
    private var googleLoginButton: some View {
        LoginButtonView(type: .google) {
            viewModel.handleGoogleSignIn(googleAuthService: googleAuthService)
        }
    }
    
    private var userSupportLabel: some View {
        if let attributedText = try? AttributedString(markdown: Texts.Settings.Sync.support) {
            return Text(attributedText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelDetails)
        } else {
            logger.error("Attributed terms string creation failed from markdown.")
            return Text(Texts.Settings.Sync.supportError)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelDetails)
        }
    }
    
    private var termsPolicyLabel: some View {
        if let attributedText = try? AttributedString(markdown: Texts.OnboardingPage.markdownTerms) {
            return Text(attributedText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelDetails)
            
        } else {
            logger.error("Attributed terms string creation failed from markdown.")
            return Text(Texts.OnboardingPage.markdownTermsError)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelDetails)
        }
    }
}

#Preview {
    SettingSyncView(appleAuthService: AppleAuthService(), googleAuthService: GoogleAuthService(networkService: .init()))
        .environmentObject(AuthNetworkService())
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}
