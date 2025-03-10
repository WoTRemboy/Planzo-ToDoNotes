//
//  CustomNavBarContainerView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/1/25.
//

import SwiftUI

struct CustomNavBarContainerView<Content: View>: View {
    
    @State private var title: String = String()
    @State private var showBackButton: Bool = false
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    internal var body: some View {
        VStack(spacing: 0) {
            CustomNavBar(
                title: title,
                showBackButton: showBackButton)
            
            content
        }
        .onPreferenceChange(CunstomNavBarTitlePreferenceKey.self, perform: { value in
            self.title = value
        })
        .onPreferenceChange(CunstomNavBarBackButtonPreferenceKey.self, perform: { value in
            self.showBackButton = value
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    CustomNavBarContainerView() {
        Text("Content")
            .customNavBarItems(title: "Title", showBackButton: true)
    }
}
