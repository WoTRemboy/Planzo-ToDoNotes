//
//  SettingAccountView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 09/09/2025.
//

import SwiftUI

struct SettingAccountView: View {
    
    @EnvironmentObject private var authService: AuthNetworkService
    
    internal var body: some View {
        content
            .padding(.top)
            .customNavBarItems(
                title: Texts.Authorization.Details.account,
                showBackButton: true)
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
        AccountDetailsRow(
            title: Texts.Authorization.Details.nickname,
            details: authService.currentUser?.name)
    }
    
    private var emailView: some View {
        AccountDetailsRow(
            title: Texts.Authorization.Details.email,
            details: authService.currentUser?.email)
    }
    
    private var planView: some View {
        AccountDetailsRow(
            title: Texts.Subscription.plan,
            details: authService.currentUser?.subscription.title,
            last: true)
    }
}

#Preview {
    SettingAccountView()
        .environmentObject(AuthNetworkService())
}
