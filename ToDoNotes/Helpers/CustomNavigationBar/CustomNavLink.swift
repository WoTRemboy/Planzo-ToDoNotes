//
//  CustomNavLink.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/1/25.
//

import SwiftUI

struct CustomNavLink<Label: View, Destination: View>: View {
    
    private let destination: Destination
    private let label: Label
    
    init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }
    
    internal var body: some View {
        NavigationLink {
            CustomNavBarContainerView() {
                    destination
                }
                .navigationBarHidden(true)
                .enableFullSwipePop(true)
        } label: {
            label
        }

    }
}

#Preview {
    NavigationStack {
        CustomNavLink(
            destination: Text("Destination")) {
                Text("Navigate")
            }
    }
}
