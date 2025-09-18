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
    
    private let namespace: Namespace.ID
    
    init(namespace: Namespace.ID) {
        self.namespace = namespace
    }
    
    internal var body: some View {
        content
            .padding(.top)
            .customNavBarItems(
                title: Texts.Authorization.Details.account,
                showBackButton: true)
            .fullScreenCover(isPresented: $viewModel.showingSubscriptionDetailsPage) {
                SubscriptionView(namespace: namespace, networkService: authService)
            }
    }
    
    private var content: some View {
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
            
            subscriptionPromoteRow
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
        SettingsProfileRow(
            title: Texts.Subscription.plan,
            details: authService.currentUser?.subscription.title,
            last: true)
    }
    
    private var subscriptionPromoteRow: some View {
        Button {
            viewModel.toggleShowingSubscriptionDetailsPage()
        } label: {
            SubscriptionPromoteRow()
        }
        .clipShape(.rect(cornerRadius: 10))
        .padding(.horizontal)
    }
}

#Preview {
    SettingAccountView(namespace: Namespace().wrappedValue)
        .environmentObject(AuthNetworkService())
        .environmentObject(SettingsViewModel(notificationsEnabled: true))
        .environmentObject(SubscriptionViewModel())
}
