//
//  SubscriptionView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 17/09/2025.
//

import SwiftUI
import OSLog
import StoreKit

/// A logger instance for debug and error messages.
private let logger = Logger(subsystem: "com.todonotes.subscription", category: "SubscriptionView")

struct SubscriptionView: View {
    
    @EnvironmentObject private var viewModel: SubscriptionViewModel
    
    @EnvironmentObject private var authService: AuthNetworkService
    @StateObject private var appleAuthService: AppleAuthService
    /// Google authentication service.
    @StateObject private var googleAuthService: GoogleAuthService
    
    @Environment(\.dismiss) private var dismiss
    
    /// Animation namespace used for matched geometry transitions.
    private let namespace: Namespace.ID
    
    @ObservedObject private var subscription = SubscriptionCoordinatorService.shared
    
    @State private var showingProductsError: Bool = false
    
    @State private var justPurchased: Bool = false
    
    
    init(namespace: Namespace.ID, networkService: AuthNetworkService) {
        self.namespace = namespace
        
        _appleAuthService = StateObject(wrappedValue: AppleAuthService(networkService: networkService))
        
        _googleAuthService = StateObject(wrappedValue: GoogleAuthService(networkService: networkService))
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Texts.DateParameters.locale)
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    internal var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SubscriptionNavBar(
                    title: Texts.Subscription.SubType.proPlan,
                    showBackButton: true)
                .zIndex(1)
                
                subscriptionContent
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .safeAreaInset(edge: .bottom) {
            safeAreaContent
        }
        .popView(isPresented: $viewModel.showingErrorAlert, onTap: {}, onDismiss: {}) {
            errorAlert
        }
        .popView(isPresented: $showingProductsError, onTap: {}, onDismiss: {
            dismiss()
        }) {
            CustomAlertView(
                title: Texts.Settings.Sync.Retry.title,
                message: Texts.Settings.Sync.Retry.content,
                primaryButtonTitle: Texts.Settings.ok,
                primaryAction: { showingProductsError = false; dismiss() }
            )
        }
        .popView(isPresented: $viewModel.showingSuccessAlert, onTap: {}, onDismiss: { dismiss() }) {
            CustomAlertView(
                title: Texts.Settings.Reset.success,
                message: viewModel.successAlertMessage,
                primaryButtonTitle: Texts.Settings.ok,
                primaryAction: {
                    viewModel.showingSuccessAlert = false
                    dismiss()
                }
            )
        }
        .navigationTransition(
            id: Texts.NamespaceID.subscriptionButton,
            namespace: namespace)
        .onAppear {
            subscription.loadProducts()
            subscription.refreshStatus()
        }
        .onChange(of: subscription.status) { _, newStatus in
            if newStatus != .loading, subscription.products.count == 0 {
                showingProductsError = true
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, _ in dismiss()
        }
        .onChange(of: justPurchased) { _, newValue in
            if newValue {
                switch subscription.status {
                case .subscribed(let expiration):
                    if let exp = expiration {
                        viewModel.setAlertMessage("\(Texts.Subscription.State.until):  \(formattedDate(exp))")
                    } else {
                        viewModel.setAlertMessage(Texts.Subscription.State.untilWithoutDate)
                    }
                    viewModel.showingSuccessAlert = true
                    justPurchased = false
                case .notSubscribed, .error:
                    justPurchased = false
                default:
                    break
                }
            }
        }
    }
    
    private var subscriptionContent: some View {
        ScrollView(showsIndicators: false) {
            subscriptionCarousel
            
            if authService.isAuthorized {
                subscriptionView
            } else {
                authView
            }
        }
        .animation(.easeInOut(duration: 0.2), value: authService.isAuthorized)
    }
    
    private var safeAreaContent: some View {
        VStack(spacing: 0) {
            if authService.isAuthorized {
                continueButton
            }
            termsPolicyLabel
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.LabelColors.labelDetails)
                .multilineTextAlignment(.center)
                .padding([.horizontal, .top])
                .padding(.bottom, hasNotch() ? 0 : 16)
        }
        .frame(maxWidth: .infinity)
        .background {
            Color.SupportColors.supportNavBar
                .shadow(color: Color.ShadowColors.navBar, radius: 15, x: 0, y: -5)
                .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.2), value: authService.isAuthorized)
    }
    
    private var subscriptionCarousel: some View {
        SubscriptionBenefitsCarousel()
            .frame(minHeight: 250)
    }
    
    private var authView: some View {
        SubscriptionLoginView(
            appleAuthService: appleAuthService,
            googleAuthService: googleAuthService)
            .padding(.top, 30)
            .transition(.blurReplace)
    }
    
    private var subscriptionView: some View {
        VStack {
            planTitle
            if shouldShowTrialToggle {
                trialToggle
            }
            subscriptionPricesView
        }
        .padding(.top, 30)
        .transition(.blurReplace)
    }
    
    private var planTitle: some View {
        Text(Texts.Subscription.Page.choosePlan)
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color.LabelColors.labelPrimary)
    }
    
    private var trialToggle: some View {
        SubscriptionTrialToggle()
            .padding(.horizontal)
            .padding(.top, 8)
    }
    
    private var shouldShowTrialToggle: Bool {
        let backendAllows = authService.currentUser?.subscription?.trialUsed == false
        let storeKitAllows = subscription.products.contains { product in
            product.id == ProSubscriptionID.annualTrial.rawValue ||
            product.id == ProSubscriptionID.monthlyTrial.rawValue
        }
        return backendAllows && storeKitAllows
    }
    
    private var subscriptionPricesView: some View {
        SubscriptionPricesView()
            .padding(.top)
    }
    
    private var continueButton: some View {
        Button {
            let productId: String = {
                if viewModel.selectedFreePlan {
                    return (viewModel.selectedSubscriptionPlan == .annual)
                    ? ProSubscriptionID.annualTrial.rawValue
                    : ProSubscriptionID.monthlyTrial.rawValue
                } else {
                    return (viewModel.selectedSubscriptionPlan == .annual)
                    ? ProSubscriptionID.annual.rawValue
                    : ProSubscriptionID.monthly.rawValue
                }
            }()
            subscription.purchase(productId: productId) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        justPurchased = true
                        authService.loadPersistedProfile()
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        viewModel.toggleShowingErrorAlert()
                    }
                }
            }
        } label: {
            Text(viewModel.selectedFreePlan
                 ? Texts.Subscription.Page.trialContinue
                 : Texts.Subscription.Page.continueButton)
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .contentTransition(.numericText())
            
                .foregroundColor(Color.LabelColors.labelReversed)
                .background(Color.LabelColors.labelPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(height: 50)
        .disabled(subscription.purchasingProductId != nil || subscription.restoreInProgress || (subscription.status == .loading))
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .transition(.blurReplace)
        .padding([.horizontal, .top], 16)
    }
        
    private var termsPolicyLabel: some View {
        if let attributedText = try? AttributedString(markdown: Texts.OnboardingPage.markdownTerms) {
            return Text(attributedText)
        } else {
            logger.error("Attributed terms string creation failed from markdown.")
            return Text(Texts.OnboardingPage.markdownTermsError)
        }
    }
    
    private var errorAlert: some View {
        CustomAlertView(
            title: Texts.Settings.Sync.Retry.title,
            message: Texts.Settings.Sync.Retry.content,
            primaryButtonTitle: Texts.Settings.ok,
            primaryAction: {
                viewModel.toggleShowingErrorAlert()
            })
    }
}

#Preview {
    SubscriptionView(namespace: Namespace().wrappedValue, networkService: AuthNetworkService())
        .environmentObject(SubscriptionViewModel())
        .environmentObject(AuthNetworkService())
}

