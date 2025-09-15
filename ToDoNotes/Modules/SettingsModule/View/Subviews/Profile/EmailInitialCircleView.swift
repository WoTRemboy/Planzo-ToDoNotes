//
//  EmailInitialCircleView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 14/09/2025.
//

import SwiftUI

struct EmailInitialCircleView: View {
    
    private let email: String
    private let type: EmailInitialCircleSize
    
    init(email: String, type: EmailInitialCircleSize) {
        self.email = email
        self.type = type
    }
    
    internal var body: some View {
        ZStack {
            Circle()
                .fill(Color.LabelColors.labelPrimary)
            
            Text(email.prefix(1).uppercased())
                .font(type.font)
                .foregroundStyle(Color.LabelColors.labelReversed)
        }
    }
}

#Preview {
    EmailInitialCircleView(email: "qwerty@gmail.com", type: .large)
}

enum EmailInitialCircleSize {
    case small
    case large
    
    internal var font: Font {
        switch self {
        case .small:
            Font.system(size: 17, weight: .medium)
        case .large:
            Font.system(size: 25, weight: .bold)
        }
    }
}
