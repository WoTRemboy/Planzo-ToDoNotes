//
//  SubscriptionView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import SwiftUI

struct SubscriptionView: View {
    
    @EnvironmentObject private var viewModel: SubscriptionViewModel
    
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
                
                SubscriptionBenefitsCarousel()
                    .frame(height: 250)
                
                planTitle
                trialToggle
                subscriptionPricesView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .safeAreaInset(edge: .bottom) {
            continueButton
        }
    }
    
    private var planTitle: some View {
        Text("Choose Your Plan")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color.LabelColors.labelPrimary)
            .padding(.top, 36)
    }
    
    private var trialToggle: some View {
        SubscriptionTrialToggle()
            .padding([.horizontal, .top], 16)
    }
    
    private var subscriptionPricesView: some View {
        SubscriptionPricesView()
            .padding(.top, 24)
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
        .padding(.bottom, 30)
    }
}

#Preview {
    SubscriptionView(namespace: Namespace().wrappedValue)
        .environmentObject(SubscriptionViewModel())
}
