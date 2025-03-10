//
//  HeightReader.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import SwiftUI

struct HeightReader: View {
    @Binding private var height: CGFloat
    
    init(height: Binding<CGFloat>) {
        self._height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    height = geometry.size.height
                }
                .onChange(of: geometry.size.height) { _, newValue in
                    withAnimation {
                        height = newValue
                    }
                }
        }
    }
}
