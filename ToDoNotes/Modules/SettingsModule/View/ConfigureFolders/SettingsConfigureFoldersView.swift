//
//  SettingsConfigureFoldersView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 21/10/2025.
//

import SwiftUI

struct SettingsConfigureFoldersView: View {
    internal var body: some View {
        dragLabel
    }
    
    private var dragLabel: some View {
        Text(Texts.Folders.Configure.dragAndDrop)
            .foregroundStyle(Color.LabelColors.labelDetails)
            .font(.system(size: 15, weight: .regular))
    }
}

#Preview {
    SettingsConfigureFoldersView()
}
