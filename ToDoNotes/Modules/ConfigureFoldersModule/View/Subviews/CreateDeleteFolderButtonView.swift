//
//  CreateDeleteFolderButtonView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 25/10/2025.
//

import SwiftUI

struct CreateDeleteFolderButtonView: View {
    
    private let type: FolderMethod
    private let action: () -> Void
    
    init(type: FolderMethod, action: @escaping () -> Void) {
        self.type = type
        self.action = action
    }
    
    internal var body: some View {
        Button {
            // Create Button Action
        } label: {
            content
                .background(Color.SupportColors.supportButton)
        }
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var content: some View {
        HStack(spacing: 4) {
            if let icon = type.icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 22)
            }
            
            Text(type.name)
                .foregroundStyle(type.color)
                .font(.system(size: 17, weight: .medium))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    CreateDeleteFolderButtonView(type: .change) {}
}
