//
//  iOS26OnboardingModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 01/03/2026.
//

import SwiftUI

struct iOS26OnboardingItem: Identifiable {
    var id: Int
    var title: String
    var subtitle: String
    var screenshot: UIImage?
    var zoomScale: CGFloat = 1
    var zoomAnchor: UnitPoint = .center
}

extension iOS26OnboardingItem {
    static func stepsSetup() -> [Self] {
        [
            .init(id: 0,
                  title: Texts.OnboardingPage.OnboardingContent.first,
                  subtitle: Texts.OnboardingPage.firstTitle,
                  screenshot: UIImage.Onboarding.first,
                  zoomScale: 2,
                  zoomAnchor: .init(x: 0, y: -0.2)),
            
                .init(id: 1,
                      title: Texts.OnboardingPage.OnboardingContent.second,
                      subtitle: Texts.OnboardingPage.secondTitle,
                      screenshot: UIImage.Onboarding.second,
                      zoomScale: 1.3,
                      zoomAnchor: .init(x: 0.5, y: -0.5)),
            
                .init(id: 2,
                      title: Texts.OnboardingPage.OnboardingContent.third,
                      subtitle: Texts.OnboardingPage.thirdTitle,
                      screenshot: UIImage.Onboarding.third,
                      zoomScale: 1.3,
                      zoomAnchor: .init(x: 0.5, y: 0)),
            
                .init(id: 3,
                      title: Texts.OnboardingPage.OnboardingContent.fourth,
                      subtitle: Texts.OnboardingPage.fourthTitle,
                      screenshot: UIImage.Onboarding.fourth,
                      zoomScale: 1.3,
                      zoomAnchor: .init(x: 0.5, y: 0.8)),
            
                .init(id: 4,
                      title: Texts.OnboardingPage.OnboardingContent.fifth,
                      subtitle: Texts.OnboardingPage.fourthTitle,
                      screenshot: UIImage.Onboarding.fifth,
                      zoomScale: 1.3,
                      zoomAnchor: .init(x: 0.5, y: 0)),
        ]
    }
}
