//
//  AboutAppView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/5/25.
//

import SwiftUI

struct AboutAppView: View {
    
    private let name: String
    private let version: String
    
    init(name: String, version: String) {
        self.name = name
        self.version = version
    }
    
    internal var body: some View {
        HStack(spacing: 16) {
            Image.Settings.about
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(.rect(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.LabelColors.labelPrimary)
                
                Text(version)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(Color.LabelColors.labelSecondary)
            }
            Spacer()
        }
    }
}

#Preview {
    AboutAppView(name: "ToDoNotes", version: "1.0 relese 25")
}
