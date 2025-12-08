//
//  SubscriptionCarouselModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import SwiftUI

/// Represents a step in the subscription process, including title, description, and image.
struct SubscriptionCarousel {
    /// Title of the subscription benefit.
    let name: String
    /// Description of what this step covers.
    let description: String
    /// Image associated with this benefit step.
    let image: Image
}

// MARK: - Carousel Step Setup

extension SubscriptionCarousel {
    static func stepsSetup() -> [SubscriptionCarousel] {
        let first = SubscriptionCarousel(
            name: Texts.Subscription.Benefits.firstTitle,
            description: Texts.Subscription.Benefits.firstDescription,
            image: .Subscription.firstBenefit)
        
        let second = SubscriptionCarousel(
            name: Texts.Subscription.Benefits.secondTitle,
            description: Texts.Subscription.Benefits.secondDescription,
            image: .Subscription.secondBenefit)
        
        let third = SubscriptionCarousel(
            name: Texts.Subscription.Benefits.thirdTitle,
            description: Texts.Subscription.Benefits.thirdDescription,
            image: .Subscription.thirdBenefit)
        
        let fourth = SubscriptionCarousel(
            name: Texts.Subscription.Benefits.fourthTitle,
            description: Texts.Subscription.Benefits.fourthDescription,
            image: .Subscription.fourthBenefit)
        
        return [first, second, third, fourth]
    }
}
