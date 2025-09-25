//
//  SubscriptionTrialToggle.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import SwiftUI

struct SubscriptionTrialToggle: View {
    
    @EnvironmentObject private var viewModel: SubscriptionViewModel
    
    internal var body: some View {
        ZStack(alignment: .trailing) {
            Text(Texts.Subscription.Page.trial)
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 60)
            
            Toggle(isOn: $viewModel.selectedFreePlan) {}
                .fixedSize()
                .background(Color.SupportColors.supportButton)
                .tint(Color.SupportColors.supportToggle)
                .scaleEffect(0.8)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.SupportColors.supportButton)
        }
    }
}

#Preview {
    SubscriptionTrialToggle()
        .environmentObject(SubscriptionViewModel())
}
