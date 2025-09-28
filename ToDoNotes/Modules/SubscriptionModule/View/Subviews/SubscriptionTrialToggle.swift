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
        Text(Texts.Subscription.Page.trial)
            .font(.system(size: 16, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
        
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
