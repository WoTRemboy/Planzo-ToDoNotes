//
//  SettingAccountView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 09/09/2025.
//

import SwiftUI

struct SettingAccountView: View {
    
    @EnvironmentObject private var authService: AuthNetworkService
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    @State private var showingPlanAlert: Bool = false
    @State private var planAlertMessage: String = ""
    
    private let namespace: Namespace.ID
    
    init(namespace: Namespace.ID) {
        self.namespace = namespace
    }
    
    internal var body: some View {
        content
            .customNavBarItems(
                title: Texts.Authorization.Details.account,
                showBackButton: true)
            .fullScreenCover(isPresented: $viewModel.showingSubscriptionDetailsPage) {
                SubscriptionView(namespace: namespace, networkService: authService)
            }
            .popView(isPresented: $showingPlanAlert, onTap: {}, onDismiss: {}) {
                infoAlert
            }
    }
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                profileImage
                
                VStack(spacing: 0) {
                    if authService.currentUser?.name != nil {
                        nicknameView
                    }
                    emailView
                    planView
                }
                .clipShape(.rect(cornerRadius: 10))
                .padding(.horizontal)
                
                if authService.currentUser?.isPremium == true {
                    VStack(spacing: 16) {
                        SettingSubFAQView()
                        
                        userSupportLabel
                            .multilineTextAlignment(.center)
                            .accentColor(Color.SupportColors.supportSubscription)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
    
    @ViewBuilder
    private var profileImage: some View {
        if let user = authService.currentUser, let url = user.avatarUrl {
            AsyncImage(url: URL(string: url)) { image in
                if let image = image.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(.circle)
                } else {
                    placeholderImage
                }
            }
        } else if let user = authService.currentUser, let email = user.email, !email.isEmpty {
            EmailInitialCircleView(email: email, type: .large)
                .frame(width: 80, height: 80)
        } else {
            placeholderImage
        }
    }
    
    private var placeholderImage: some View {
        Image.Settings.signIn
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .clipShape(.circle)
    }
    
    private var nicknameView: some View {
        SettingsProfileRow(
            title: Texts.Authorization.Details.nickname,
            details: authService.currentUser?.name)
    }
    
    private var emailView: some View {
        SettingsProfileRow(
            title: Texts.Authorization.Details.email,
            details: authService.currentUser?.email)
    }
    
    private var planView: some View {
        Button {
            if authService.currentUser?.isPremium == true {
                if let message = subscriptionEndMessage() {
                    planAlertMessage = message
                } else {
                    planAlertMessage = Texts.Settings.Plans.error
                }
                showingPlanAlert = true
            } else {
                viewModel.toggleShowingSubscriptionDetailsPage()
            }
        } label: {
            SettingsProfileRow(
                title: Texts.Subscription.plan,
                details: planTitle,
                chevron: true,
                last: true)
        }
    }
    
    private var subscriptionPromoteRow: some View {
        Button {
            viewModel.toggleShowingSubscriptionDetailsPage()
        } label: {
            SubscriptionPromoteRow()
        }
        .clipShape(.rect(cornerRadius: 10))
    }
    
    private var userSupportLabel: some View {
        if let attributedText = try? AttributedString(markdown: Texts.Settings.Sync.support) {
            return Text(attributedText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelDetails)
        } else {
            return Text(Texts.Settings.Sync.supportError)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelDetails)
        }
    }
    
    private var infoAlert: some View {
        CustomAlertView(
            title: Texts.Settings.Plans.title,
            message: planAlertMessage,
            primaryButtonTitle: Texts.Settings.ok,
            primaryAction: {
                showingPlanAlert = false
            }
        )
    }
    
    private var planTitle: String {
        if authService.currentUser?.isPremium == true {
            Texts.Settings.Plans.pro
        } else {
            Texts.Settings.Plans.free
        }
    }
    
    // MARK: - Helpers
    
    private func subscriptionEndMessage() -> String? {
        guard let user = authService.currentUser,
              user.isPremium == true,
              let isoString = user.subscription?.validUntil,
              let date = ISO8601DateFormatter().date(from: isoString) else {
            return nil
        }
        let formatted = formattedDate(date)
        return "\(Texts.Subscription.State.until): \(formatted)"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    SettingAccountView(namespace: Namespace().wrappedValue)
        .environmentObject(AuthNetworkService())
        .environmentObject(SettingsViewModel(notificationsEnabled: true))
        .environmentObject(SubscriptionViewModel())
}
