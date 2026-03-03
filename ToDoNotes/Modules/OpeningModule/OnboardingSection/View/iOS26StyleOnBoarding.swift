//
//  iOS26StyleOnBoarding.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 01/03/2026.
//

import SwiftUI

@available(iOS 26.0, *)
struct iOS26StyleOnBoarding: View {
    var tint: Color = .SupportColors.supportSubscription
    var items: [iOS26OnboardingItem]
    var onComplete: () -> Void = { }
    
    @Binding private var currentIndex: Int
    @State private var screenshotSize: CGSize = .zero
    
    init(
        items: [iOS26OnboardingItem],
        currentIndex: Binding<Int> = .constant(0),
        tint: Color = .SupportColors.supportSubscription,
        onComplete: @escaping () -> Void = { }
    ) {
        self.items = items
        self._currentIndex = currentIndex
        self.tint = tint
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            screenshotView()
                .compositingGroup()
                .scaleEffect(
                    items[currentIndex].zoomScale,
                    anchor: items[currentIndex].zoomAnchor
                )
                .padding(.top, 35)
                .padding(.horizontal, 30)
                .padding(.bottom, 220)
            VStack(spacing: 10) {
                textContentView()
                indicatorView()
                continueButton()
            }
            .padding(.top, 20)
            .padding(.horizontal, 15)
            .frame(height: 210)
            .background {
                variableGlassBlur(15)
            }
            
            backButton()
        }
    }
    
    @ViewBuilder
    func screenshotView() -> some View {
        let shape = ConcentricRectangle(corners: .concentric, isUniform: true)

        GeometryReader { proxy in
            let size = proxy.size

            Rectangle()
                .fill(Color.BackColors.backDefault)

            ZStack {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]

                    Group {
                        if let screenshot = item.screenshot {
                            Image(uiImage: screenshot)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onGeometryChange(for: CGSize.self) {
                                    $0.size
                                } action: { newValue in
                                    screenshotSize = newValue
                                }
                                .clipShape(shape)
                        } else {
                            Rectangle()
                                .fill(Color.BackColors.backDefault)
                        }
                    }
                    .frame(width: size.width, height: size.height)
                    .opacity(currentIndex == index ? 1 : 0)
                    .transition(.blurReplace)
                }
            }
            .animation(animation, value: currentIndex)
        }
        .clipShape(shape)
        .overlay {
            if screenshotSize != .zero {
                ZStack {
                    shape
                        .stroke(.white, lineWidth: 6)
                    shape
                        .stroke(.black, lineWidth: 4)
                    shape
                        .stroke(.black, lineWidth: 6)
                        .padding(4)
                }
                .padding(-6)
            }
        }
        .frame(
            maxWidth: screenshotSize.width == 0 ? nil : screenshotSize.width,
            maxHeight: screenshotSize.height == 0 ? nil : screenshotSize.height
        )
        .containerShape(RoundedRectangle(cornerRadius: deviceCornerRadius))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    func textContentView() -> some View {
        GeometryReader {
            let size = $0.size
            
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        let item = items[index]
                        let isActive = currentIndex == index
                        
                        VStack(spacing: 6) {
                            Text(item.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .foregroundStyle(Color.LabelColors.labelPrimary)
                            
                            Text(item.subtitle)
                                .font(.callout)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.LabelColors.labelDetails)
                        }
                        .frame(width: size.width)
                        .compositingGroup()
                        .blur(radius: isActive ? 0 : 30)
                        .opacity(isActive ? 1 : 0)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollDisabled(true)
            .scrollTargetBehavior(.paging)
            .scrollClipDisabled()
            .scrollPosition(id: .init(get: {
                return currentIndex
            }, set: { _ in }))
        }
    }
    
    @ViewBuilder
    func continueButton() -> some View {
        Button {
            if currentIndex == items.count - 1 {
                onComplete()
            }
            
            withAnimation(animation) {
                currentIndex = min(currentIndex + 1, items.count - 1)
            }
        } label: {
            Text(currentIndex == items.count - 1 ? Texts.Authorization.withoutAuth : Texts.OnboardingPage.next)
                .fontWeight(.medium)
                .contentTransition(.numericText())
                .padding(.vertical, 6)
                .foregroundStyle(Color.LabelColors.labelWhite)
        }
        .tint(tint)
        .buttonStyle(.glassProminent)
        .buttonSizing(.flexible)
        .padding(.horizontal, 30)
    }
    
    @ViewBuilder
    func indicatorView() -> some View {
        HStack(spacing: 6) {
            ForEach(items.indices, id: \.self) { index in
                let isActive: Bool = currentIndex == index
                
                Capsule()
                    .fill(Color.LabelColors.labelPrimary.opacity(isActive ? 1 : 0.4))
                    .frame(width: isActive ? 12: 8, height: isActive ? 12 : 8)
            }
        }
    }
    
    @ViewBuilder
    func backButton() -> some View {
        Button {
            withAnimation(animation) {
                currentIndex = max(currentIndex - 1, 0)
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.title3)
                .frame(width: 20, height: 30)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, 16)
        .padding(.top, 5)
    }
    
    @ViewBuilder
    func variableGlassBlur(_ radius: CGFloat) -> some View {
        let tint: Color = .BackColors.backDefault.opacity(0.5)
        Rectangle()
            .fill(.clear)
            .glassEffect(.clear.tint(tint), in: .rect)
            .blur(radius: radius)
            .padding([.horizontal, .bottom], -radius * 2)
            .opacity(items[currentIndex].zoomScale != 1 ? 1 : 0)
            .ignoresSafeArea()
    }
    
    var deviceCornerRadius: CGFloat {
        if let imageSize = items.first?.screenshot?.size {
            let ratio = screenshotSize.height / imageSize.height
            let actualCornerRadius: CGFloat = 190
            return actualCornerRadius * ratio
        }
        return 0
    }
    
    var animation: Animation {
        .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }
}

#Preview {
    Group {
        if #available(iOS 26.0, *) {
            iOS26StyleOnBoarding(items: iOS26OnboardingItem.stepsSetup())
        } else {
            EmptyView()
        }
    }
}
