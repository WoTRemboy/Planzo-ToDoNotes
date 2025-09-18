//
//  SubscriptionView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import SwiftUI

struct SubscriptionView: View {
    
    @EnvironmentObject private var viewModel: SubscriptionViewModel
    @EnvironmentObject private var authService: AuthNetworkService
    
    /// Animation namespace used for matched geometry transitions.
    private let namespace: Namespace.ID
    
    init(namespace: Namespace.ID) {
        self.namespace = namespace
    }
    
    internal var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SubscriptionNavBar(
                    title: Texts.Subscription.SubType.proPlan,
                    showBackButton: true)
                .zIndex(1)
                
                ScrollView(showsIndicators: false) {
                    subscriptionCarousel
                    
                    if authService.isAuthorized {
                        subscriptionView
                    } else {
                        authView
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                if authService.isAuthorized {
                    continueButton
                }
                HStack(spacing: 40) {
                    termsPolicyButton(type: .termsOfService)
                    termsPolicyButton(type: .privacyPolicy)
                }
                .padding([.horizontal, .top])
                .padding(.bottom, hasNotch() ? 0 : 16)
            }
            .frame(maxWidth: .infinity)
            .background {
                Color.BackColors.backDefault
                    .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: -5)
                    .ignoresSafeArea()
            }
        }
        .navigationTransition(
            id: Texts.NamespaceID.subscriptionButton,
            namespace: namespace)
    }
    
    private var subscriptionCarousel: some View {
        SubscriptionBenefitsCarousel()
            .frame(minHeight: 250)
    }
    
    private var authView: some View {
        SubscriptionLoginView()
            .padding(.top, 30)
    }
    
    private var subscriptionView: some View {
        VStack {
            planTitle
            trialToggle
            subscriptionPricesView
        }
        .padding(.top, 30)
    }
    
    private var planTitle: some View {
        Text("Choose Your Plan")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color.LabelColors.labelPrimary)
    }
    
    private var trialToggle: some View {
        SubscriptionTrialToggle()
            .padding(.horizontal)
            .padding(.top, 8)
    }
    
    private var subscriptionPricesView: some View {
        SubscriptionPricesView()
            .padding(.top)
    }
    
    private var continueButton: some View {
        Button {
            // Continue Button Action
        } label: {
            Text("Continue")
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
                .foregroundColor(Color.LabelColors.labelReversed)
                .background(Color.LabelColors.labelPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .padding([.horizontal, .top], 16)
    }
        
    private func termsPolicyButton(type: SupportLink) -> some View {
        Button {
            viewModel.openSupportLink(url: type.url)
        } label: {
            Text(type.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelDetails)
        }
    }
}

#Preview {
    SubscriptionView(namespace: Namespace().wrappedValue)
        .environmentObject(SubscriptionViewModel())
        .environmentObject(AuthNetworkService())
}
