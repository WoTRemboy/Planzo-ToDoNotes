//
//  SubscriptionLoginView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 18/09/2025.
//

import SwiftUI

struct SubscriptionLoginView: View {
    
    @EnvironmentObject private var viewModel: SubscriptionViewModel
    @ObservedObject var appleAuthService: AppleAuthService
    @ObservedObject var googleAuthService: GoogleAuthService
    
    internal var body: some View {
        VStack(spacing: 16) {
            titleView
            loginButtons
        }
        .padding(.horizontal)
    }
    
    private var titleView: some View {
        Text(Texts.Authorization.title)
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color.LabelColors.labelPrimary)
    }
    
    private var loginButtons: some View {
        VStack(spacing: 16) {
            LoginButtonView(type: .apple) {
                viewModel.handleAppleSignIn(appleAuthService: appleAuthService)
            }
//            LoginButtonView(type: .google) {
//                viewModel.handleGoogleSignIn(googleAuthService: googleAuthService)
//            }
        }
    }
}

#Preview {
    let networkService = AuthNetworkService()
    SubscriptionLoginView(
        appleAuthService: AppleAuthService(networkService: networkService),
        googleAuthService: GoogleAuthService(networkService: networkService)
    )
        .environmentObject(SubscriptionViewModel())
}
