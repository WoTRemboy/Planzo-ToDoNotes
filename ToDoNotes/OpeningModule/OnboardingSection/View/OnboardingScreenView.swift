//
//  OnboardingScreenView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import Foundation
import SwiftUI

/// View displaying the onboarding process or the main `EditorView` if onboarding is complete.
struct OnboardingScreenView: View {
    
    /// View model controlling the onboarding state.
    @EnvironmentObject private var viewModel: OnboardingViewModel
    
    // MARK: - Body
    
    internal var body: some View {
//        if viewModel.skipOnboarding {
//            ContentView()
//        } else {
            VStack(spacing: 0) {
                content
                progressCircles
                actionButton
                skipButton
            }
//        }
    }
    
    // MARK: - Content
    
    /// Displays the onboarding steps as a tab view.
    private var content: some View {
        TabView(selection: $viewModel.currentStep) {
            ForEach(0 ..< viewModel.stepsCount, id: \.self) { index in
                VStack(spacing: 0) {
                    viewModel.steps[index].image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .clipShape(.rect(cornerRadius: 16))
                    
                    Text(viewModel.steps[index].name)
                        .font(.system(size: 18))
                        .fontWeight(.regular)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    Text(viewModel.steps[index].description)
                        .font(.system(size: 14))
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .padding(.top, 3)
                        .frame(width: 238)
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    // MARK: - Progress Circles
    
    /// Displays the progress indicator for the onboarding steps.
    private var progressCircles: some View {
        HStack {
            ForEach(0 ..< viewModel.stepsCount, id: \.self) { step in
                if step == viewModel.currentStep {
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color.gray)
                        .transition(.scale)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                } else {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(Color.labelDisable)
                        .transition(.scale)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                }
            }
        }
        .animation(.easeInOut, value: viewModel.currentStep)
    }
    
    // MARK: - Action Button
    
    /// Button for advancing to the next step or completing onboarding.
    private var actionButton: some View {
        Button {
            switch viewModel.buttonType {
            case .nextPage:
                viewModel.nextStep()
            case .getStarted:
                viewModel.getStarted()
            }
        } label: {
            switch viewModel.buttonType {
            case .nextPage:
                Text(Texts.OnboardingPage.next)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .getStarted:
                Text(Texts.OnboardingPage.start)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .foregroundStyle(Color.white)
        .tint(Color.black)
        .buttonStyle(.bordered)
        
        .padding(.horizontal)
        .padding(.top, 30)
        
        .animation(.easeInOut, value: viewModel.buttonType)
    }
    
    // MARK: - Skip Button
    
    /// Button allowing users to skip to the last onboarding step.
    private var skipButton: some View {
        Text(Texts.OnboardingPage.skip)
            .font(.system(size: 14))
            .fontWeight(.light)
            .foregroundStyle(viewModel.buttonType == .nextPage ? Color.labelSecondary : Color.clear)
        
            .padding(.top)
            .padding(.bottom, hasNotch() ? 20 : 16)
        
            .onTapGesture {
                viewModel.skipSteps()
            }
            .disabled(viewModel.buttonType == .getStarted)
            .animation(.easeInOut, value: viewModel.buttonType)
    }
}

// MARK: - Preview

#Preview {
    OnboardingScreenView()
        .environmentObject(OnboardingViewModel())
}

