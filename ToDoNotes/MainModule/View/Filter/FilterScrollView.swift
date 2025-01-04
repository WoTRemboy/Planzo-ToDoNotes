//
//  FilterScrollView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

struct FilterScrollView: View {
    
    @EnvironmentObject private var viewModel: MainViewModel
    
    internal var body: some View {
        ScrollView(.horizontal) {
            content
        }
        .scrollIndicators(.hidden)
    }
    
    private var content: some View {
        HStack {
            ForEach(Filter.allCases, id: \.self) { filter in
                FilterCell(name: filter.name,
                           selected: viewModel.compareFilters(from: filter))
                .onTapGesture {
                    viewModel.setFilter(to: filter)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    FilterScrollView()
        .environmentObject(MainViewModel())
}
