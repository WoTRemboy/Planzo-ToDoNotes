//
//  SplashScreenView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI
import SwiftData

struct SplashScreenView: View {
    
    // MARK: - Properties
    
    // Show splash screen toggle
    @State private var isActive = false
    @State private var id = 0
    
    private let texts = [String(), Texts.SplashScreen.title]
    
    // MARK: - Body view
    
    internal var body: some View {
        if isActive {
            // Step to the main view
            OnboardingScreenView()
                .environmentObject(OnboardingViewModel())
        } else {
            // Shows splash screnn
            content
                .onAppear {
                    // Then hides view after 1s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
        }
    }
    
    // MARK: - Main vontent
    
    private var content: some View {
        ZStack {
            // Background color
            Color.BackColors.backDefault
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Logo image
                Image.Placeholder.previewIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                
                Text(texts[id])
                    .foregroundStyle(Color.LabelColors.labelSecondary)
                    .font(.system(size: 55, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 30)
            }
            .contentTransition(.numericText())
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
                    withAnimation {
                        id += 1
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplashScreenView()
}
