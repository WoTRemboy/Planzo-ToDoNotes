//
//  SettingSyncFAQView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 11/11/2025.
//

import SwiftUI

struct SettingSyncFAQView: View {
    
    @State private var isFAQExpanded = false
    
    internal var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleLabel
            VStack(spacing: 0) {
                expandButton
                if isFAQExpanded {
                    expandedContent
                }
            }
            .background(Color.SupportColors.supportButton)
            .clipShape(.rect(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var titleLabel: some View {
        Text(Texts.Settings.Sync.questions)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelSecondary)
            .padding(.leading)
            .padding(.bottom, 6)
    }
    
    private var expandButton: some View {
        HStack {
            Text(Texts.Settings.Sync.FAQ.title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .multilineTextAlignment(.leading)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundStyle(Color.LabelColors.labelPrimary)
                .rotationEffect(.degrees(isFAQExpanded ? 180 : 0))
                .animation(.easeInOut(duration: 0.3), value: isFAQExpanded)
        }
        .padding(16)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring) {
                isFAQExpanded.toggle()
            }
        }
        .sensoryFeedback(.selection, trigger: isFAQExpanded)
    }
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .overlay(Color.LabelColors.labelSecondary)
            
            Text(Texts.Settings.Sync.FAQ.first)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
            bulletsListView
        }
        .padding([.horizontal, .bottom], 16)
        .transition(.blurReplace)
    }
    
    private var bulletsListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(FAQBullet.allCases, id: \.self) { bullet in
                bulletView(bullet.title)
            }
        }
    }

    private func bulletView(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image.Selector.bullet
                .resizable()
                .frame(width: 8, height: 8)
                .padding(.top, 5)
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
        }
    }
}

#Preview {
    SettingSyncFAQView()
}
