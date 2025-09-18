//
//  SubscriptionViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import Foundation
import SwiftUI

final class SubscriptionViewModel: ObservableObject {
    
    @Published internal var selectedFreePlan: Bool = false
    @Published internal var selectedSubscriptionPlan: SubscriptionPlan = .annual
    
    private(set) var steps = SubscriptionCarousel.stepsSetup()
    
    internal var pages: [Int] {
        Array(0..<steps.count)
    }
    
    internal func changePlan(_ plan: SubscriptionPlan) {
        withAnimation(.easeInOut(duration: 0.1)) {
            selectedSubscriptionPlan = plan
        }
    }
    
    internal func isSelectedPlan(_ plan: SubscriptionPlan) -> Bool {
        plan == selectedSubscriptionPlan
    }
    
    internal func strokeColor(for plan: SubscriptionPlan) -> Color {
        plan == selectedSubscriptionPlan ? .supportSubscription : .labelSecondary
    }
    
    internal func openSupportLink(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
}
