//
//  SubscriptionLoginView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 18/09/2025.
//

import SwiftUI

struct SubscriptionLoginView: View {
    
    @EnvironmentObject private var viewModel: SubscriptionViewModel
    
    internal var body: some View {
        VStack(spacing: 16) {
            titleView
            loginButtons
        }
        .padding(.horizontal)
    }
    
    private var titleView: some View {
        Text("Authorization")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color.LabelColors.labelPrimary)
    }
    
    private var loginButtons: some View {
        VStack(spacing: 16) {
            LoginButtonView(type: .apple) {}
            LoginButtonView(type: .google) {}
        }
    }
}

#Preview {
    SubscriptionLoginView()
        .environmentObject(SubscriptionViewModel())
}
