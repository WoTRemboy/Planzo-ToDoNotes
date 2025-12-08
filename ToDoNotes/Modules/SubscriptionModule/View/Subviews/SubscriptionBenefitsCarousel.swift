//
//  SubscriptionBenefitsCarousel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import SwiftUI
import SwiftUIPager

struct SubscriptionBenefitsCarousel: View {
    
    /// Current page tracker for the pager.
    @StateObject private var page: Page = .first()
    
    @EnvironmentObject private var viewModel: SubscriptionViewModel
    
    internal var body: some View {
        VStack(spacing: 0) {
            carousel
            progressCircles
        }
    }
    
    private var carousel: some View {
        Pager(page: page,
              data: viewModel.pages,
              id: \.self) { index in
            VStack(spacing: 0) {
                viewModel.steps[index].image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 130)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(.horizontal)
                
                Text(viewModel.steps[index].name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding(.top, 20)
                    .padding(.horizontal)
                
                Text(viewModel.steps[index].description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding(.top, 4)
                    .padding(.horizontal)
            }
            .tag(index)
        }
              .interactive(scale: 0.8)
              .itemSpacing(10)
              .itemAspectRatio(1.0)
              .expandPageToEdges()
        
              .swipeInteractionArea(.allAvailable)
              .horizontal()
    }
    
    private var progressCircles: some View {
        HStack {
            ForEach(viewModel.pages, id: \.self) { step in
                if step == page.index {
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(Color.LabelColors.labelPrimary)
                        .transition(.scale)
                } else {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundStyle(Color.labelDisable)
                        .transition(.scale)
                }
            }
        }
    }
}

#Preview {
    SubscriptionBenefitsCarousel()
        .environmentObject(SubscriptionViewModel())
}
