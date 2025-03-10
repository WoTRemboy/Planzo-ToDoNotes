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
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                scrollTabsContent(proxy: proxy)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func scrollTabsContent(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 8) {
            ForEach(Filter.allCases, id: \.self) { filter in
                FilterCell(filter: filter,
                           selected: viewModel.compareFilters(with: filter))
                .frame(height: 35)
                .id(filter)
                .onTapGesture {
                    viewModel.setFilter(to: filter)
                    withAnimation {
                        proxy.scrollTo(filter, anchor: .center)
                    }
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
