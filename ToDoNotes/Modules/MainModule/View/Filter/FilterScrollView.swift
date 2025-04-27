//
//  FilterScrollView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

/// A horizontally scrolling filter bar allowing users to select task filters (e.g., active, completed, deleted).
struct FilterScrollView: View {
    
    @EnvironmentObject private var viewModel: MainViewModel
    
    // MARK: - Body
    
    internal var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                scrollTabsContent(proxy: proxy)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Scroll Content
    
    /// Displays all filter cells inside a horizontally scrolling HStack.
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
                }
            }
            .onChange(of: viewModel.selectedFilter) { _, newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    FilterScrollView()
        .environmentObject(MainViewModel())
}
