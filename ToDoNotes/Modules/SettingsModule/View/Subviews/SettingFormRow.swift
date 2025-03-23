//
//  SettingFormRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/14/25.
//

import SwiftUI

struct SettingFormRow: View {
    
    private let title: String
    private let image: Image?
    private let details: String?
    private let chevron: Bool
    private let check: Bool
    private let last: Bool
    
    init(title: String, image: Image? = nil,
         details: String? = nil, chevron: Bool = false,
         check: Bool = false, last: Bool = false) {
        self.title = title
        self.image = image
        self.details = details
        self.chevron = chevron
        self.check = check
        self.last = last
    }
    
    internal var body: some View {
        HStack {
            leftLabel
            
            Spacer()
            if let details {
                Text(details)
                    .font(.system(size: 13,
                                  weight: .regular))
                    .lineLimit(1)
                    .foregroundStyle(Color.LabelColors.labelSecondary)
            }
            
            if chevron {
                Image.Settings.chevron
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            
            if check {
                Image.Settings.check
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.accentColor)
            }
        }
        
        .padding(.horizontal, 14)
        .frame(height: 56)
        
        .background(alignment: .bottom) {
            if !last {
                Rectangle()
                    .foregroundStyle(Color.LabelColors.labelSecondary)
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)
            }
        }
        .background {
            Color.SupportColors.supportButton
        }
        
    }
    
    private var leftLabel: some View {
        HStack(alignment: .center, spacing: 8) {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 5))
                    .frame(width: 22, height: 22)
            }
            
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
        }
    }
}


#Preview {
    SettingFormRow(title: "Title",
                   image: Image.Settings.appearance,
                   details: "hi",
                   chevron: true,
                   check: true,
                   last: false)
}
