//
//  SubscriptionPricesView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import SwiftUI

struct SubscriptionPricesView: View {
    
    @EnvironmentObject private var viewModel: SubscriptionViewModel
    
    internal var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            annualButton
            monthlyButton
        }
        .sensoryFeedback(.selection, trigger: viewModel.selectedSubscriptionPlan)
    }
    
    private var annualButton: some View {
        Button {
            viewModel.changePlan(.annual)
        } label: {
            VStack(spacing: 0) {
                saveBanner
                    .zIndex(1)
                priceTile(type: .annual)
            }
            .contentShape(Rectangle())
        }
        .padding(.leading)
        .buttonStyle(.plain)
    }
    
    private var monthlyButton: some View {
        Button {
            viewModel.changePlan(.monthly)
        } label: {
            priceTile(type: .monthly)
                .contentShape(Rectangle())
        }
        .padding(.trailing)
        .buttonStyle(.plain)
    }
    
    private func priceTile(type: SubscriptionPlan) -> some View {
        VStack(spacing: 8) {
            Text(type.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelPrimary)
            
            Text("$\(type.price)")
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelPrimary)
            
            Text("($\(type.month)/month)")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelSecondary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background {
            let corners: UIRectCorner
            if type == .annual {
                corners = [.bottomLeft, .bottomRight]
            } else {
                corners = [.allCorners]
            }
            
            return RoundedCorner(radius: 10, corners: corners)
                .stroke(viewModel.strokeColor(for: type), lineWidth: 2)
                .foregroundStyle(Color.clear)
        }
        .overlay(alignment: .bottomTrailing) {
            if viewModel.isSelectedPlan(type) {
                checkView
            }
        }
    }
    
    private var saveBanner: some View {
        Text("Save $12")
            .textCase(.uppercase)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelWhite)
        
            .frame(maxWidth: .infinity)
            .frame(height: 13)
            .padding(.vertical, 8)
        
            .background {
                RoundedCorner(radius: 10, corners: [.topLeft, .topRight])
                    .stroke(Color.SupportColors.supportSubscription, lineWidth: 2)
                    .fill(Color.SupportColors.supportSubscription)
            }
            .padding(.bottom, -1)
    }
    
    private var checkView: some View {
        Image.Subscription.check
            .resizable()
            .frame(width: 12, height: 12)
            .padding(10)
        
            .transition(.scale)
            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedSubscriptionPlan)
    }
}

#Preview {
    SubscriptionPricesView()
        .environmentObject(SubscriptionViewModel())
}


enum SubscriptionPlan {
    case annual
    case monthly
    
    internal var title: String {
        switch self {
        case .annual:
            "Annual Plan"
        case .monthly:
            "Monthly Plan"
        }
    }
    
    internal var price: Int {
        switch self {
        case .annual:
            120
        case .monthly:
            15
        }
    }
    
    internal var month: Int {
        switch self {
        case .annual:
            12
        case .monthly:
            15
        }
    }
}


