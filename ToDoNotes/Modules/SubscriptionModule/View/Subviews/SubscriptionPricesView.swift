//
//  SubscriptionPricesView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import SwiftUI
import StoreKit

struct SubscriptionPricesView: View {
    
    @EnvironmentObject private var viewModel: SubscriptionViewModel
    @ObservedObject private var subscription = SubscriptionCoordinatorService.shared
    
    private func currentProductID(for plan: SubscriptionPlan) -> ProSubscriptionID {
        switch (plan, viewModel.selectedFreePlan) {
        case (.annual, true): return .annualTrial
        case (.annual, false): return .annual
        case (.monthly, true): return .monthlyTrial
        case (.monthly, false): return .monthly
        }
    }
    
    private func skProduct(for id: ProSubscriptionID) -> Product? {
        subscription.products.first { $0.id == id.rawValue }
    }

    private func currencyString(_ value: Decimal, product: Product) -> String {
        return product.priceFormatStyle.format(value)
    }

    private func perMonthString(for product: Product, months: Int) -> String {
        guard months > 0 else { return product.displayPrice }
        let perMonth = (product.price as NSDecimalNumber).decimalValue / Decimal(months)
        return currencyString(perMonth, product: product)
    }
    
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
        let selectedProduct: Product? = {
            let id = currentProductID(for: type)
            return skProduct(for: id)
        }()
        
        return VStack(spacing: 8) {
            Text(type.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            Text(selectedProduct?.displayPrice ?? "--")
                .font(.system(size: 25, weight: .bold))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            let monthText: String = {
                if let p = selectedProduct {
                    if type == .annual {
                        return "(\(perMonthString(for: p, months: 12))/\(Texts.Subscription.Page.month))"
                    } else {
                        return "(\(perMonthString(for: p, months: 1))/\(Texts.Subscription.Page.month))"
                    }
                } else {
                    return "--/\(Texts.Subscription.Page.month))"
                }
            }()
            Text(monthText)
                .textCase(.lowercase)
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
        let annual = skProduct(for: currentProductID(for: .annual))
        let monthly = skProduct(for: currentProductID(for: .monthly))
        let savingsText: String = {
            if let a = annual, let m = monthly {
                let aPrice = (a.price as NSDecimalNumber).decimalValue
                let mPrice = (m.price as NSDecimalNumber).decimalValue
                let yearlyMonthly = mPrice * 12
                let diff = max(0, yearlyMonthly - aPrice)
                if diff > 0 {
                    return "\(Texts.Subscription.Page.save) \(currencyString(diff, product: a))"
                }
            }
            return "\(Texts.Subscription.Page.save) --" // fallback to previous mock
        }()
        
        return Text(savingsText)
            .textCase(.uppercase)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelWhite)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .frame(height: 13)
            .padding(8)
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
            Texts.Subscription.annual
        case .monthly:
            Texts.Subscription.monthly
        }
    }
}

