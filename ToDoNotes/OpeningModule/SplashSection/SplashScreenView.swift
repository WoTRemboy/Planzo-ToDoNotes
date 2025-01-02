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
                    // Then hides view after 0.5s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                Image.Placeholder.image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                
                Text(Texts.SplashScreen.title)
                    .font(.title)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplashScreenView()
}
