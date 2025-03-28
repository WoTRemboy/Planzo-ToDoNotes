//
//  OnboardingScreenView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI
import SwiftUIPager

/// View displaying the onboarding process or the main `RootView` if onboarding is complete.
struct OnboardingScreenView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    /// View model controlling the onboarding state.
    @StateObject private var viewModel = OnboardingViewModel()
    
    /// Current page tracker for the pager.
    @StateObject private var page: Page = .first()
    
    // MARK: - Body
    
    internal var body: some View {
        if viewModel.skipOnboarding {
            RootView {
                ContentView()
                    .environmentObject(TabRouter())
            }
        } else {
            VStack(spacing: 0) {
                content
                progressCircles
                selectPageButtons
                skipButton
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Content
    
    /// Displays the onboarding steps using a Pager.
    private var content: some View {
        Pager(page: page,
              data: viewModel.pages,
              id: \.self) { index in
                VStack(spacing: 0) {
                    viewModel.steps[index].image
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                        .padding(.horizontal)
                    
                    Text(viewModel.steps[index].name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.LabelColors.labelPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .frame(width: index == 1 ? 350 : 270)
                        .padding(.top, hasNotch() ? 24 : 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .tag(index)
        }
              .interactive(scale: 0.8)
              .itemSpacing(10)
              .itemAspectRatio(1.0)
              .expandPageToEdges()
        
              .swipeInteractionArea(.allAvailable)
              .multiplePagination()
              .horizontal()
    }
    
    // MARK: - Progress Circles
    
    /// Displays the progress indicator for the onboarding steps.
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
        .padding(.top)
    }
    
    // MARK: - Page Buttons
    
    private var selectPageButtons: some View {
        VStack(spacing: 16) {
            if !viewModel.isLastPage(current: page.index) {
                nextPageButton
//                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .transition(.blurReplace)
            } else {
                nextPageButton
//                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .transition(.blurReplace)
            }
        }
    }
    
    // MARK: - Action Button
    
    /// Button for advancing to the next step or completing onboarding.
    private var nextPageButton: some View {
        Button {
            if !viewModel.isLastPage(current: page.index) {
                withAnimation {
                    page.update(.next)
                }
            } else {
                viewModel.transferToMainPage()
            }
        } label: {
            Text(!viewModel.isLastPage(current: page.index) ? Texts.OnboardingPage.next : Texts.OnboardingPage.start)
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
                .foregroundColor(Color.LabelColors.labelReversed)
                .background(Color.LabelColors.labelPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - Sign with Apple Button
    
    private var signWithAppleButton: some View {
        Button {
            viewModel.startAppleSignIn()
        } label: {
            HStack {
                Image.LoginPage.appleLogo
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(Texts.OnboardingPage.appleLogin)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.LabelColors.labelReversed)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.ButtonColors.appleLogin)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .clipShape(.rect(cornerRadius: 10))
        .shadow(radius: 2)
        .frame(height: 50)
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    // MARK: - Sign with Google Button
    
    private var signWithGoogleButton: some View {
        Button {
            //viewModel.googleAuthorization()
        } label: {
            HStack {
                Image.LoginPage.googleLogo
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(Texts.OnboardingPage.googleLogin)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.white)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .clipShape(.rect(cornerRadius: 10))
        .shadow(radius: 2)
        .frame(height: 50)
        .padding(.horizontal)
    }
    
    // MARK: - Skip Button
    
    /// Button allowing users to skip to the last onboarding step.
    private var skipButton: some View {
        Text(!viewModel.isLastPage(current: page.index) ? Texts.OnboardingPage.skip : Texts.OnboardingPage.withoutAuth)
            .font(.system(size: 14))
            .fontWeight(.medium)
            .foregroundStyle(
                !viewModel.isLastPage(current: page.index) ?
                Color.LabelColors.labelPrimary :
                    Color.clear)
        
            .padding(.top)
            .padding(.bottom, hasNotch() ? 20 : 16)
        
            .onTapGesture {
                if !viewModel.isLastPage(current: page.index) {
                    withAnimation {
                        page.update(.moveToLast)
                    }
                }
            }
            .animation(.easeInOut, value: page.index)
    }
}

// MARK: - Preview

#Preview {
    OnboardingScreenView()
        .environmentObject(OnboardingViewModel())
}
