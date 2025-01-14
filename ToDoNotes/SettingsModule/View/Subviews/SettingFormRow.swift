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
    
    init(title: String, image: Image? = nil,
         details: String? = nil, chevron: Bool = false, check: Bool = false) {
        self.title = title
        self.image = image
        self.details = details
        self.chevron = chevron
        self.check = check
    }
    
    internal var body: some View {
        HStack {
            leftLabel
            
            Spacer()
            if let details {
                Text(details)
                    .font(.system(size: 15, weight: .regular))
                    .lineLimit(1)
                    .foregroundStyle(Color.LabelColors.labelSecondary)
            }
            
            if chevron {
                Image.Settings.chevron
                    .font(.system(size: 13, weight: .medium))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.LabelColors.labelDetails)
            }
            
            if check {
                Image.Settings.check
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.accentColor)
            }
        }
    }
    
    private var leftLabel: some View {
        HStack(alignment: .center, spacing: 16) {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 5))
                    .frame(width: 30)
            }
            
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.LabelColors.labelPrimary)
        }
    }
}


#Preview {
    SettingFormRow(title: "Title", image: Image.Settings.appearance, details: "hi", chevron: true, check: true)
}
