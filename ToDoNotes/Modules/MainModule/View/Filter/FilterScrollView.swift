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
        Group {
            if #available(iOS 26.0, *) {
                segmentedPicker
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        scrollTabsContent(proxy: proxy)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
    
    private var segmentedPicker: some View {
        Picker(String(), selection: Binding(
            get: { viewModel.selectedFilter },
            set: { viewModel.setFilter(to: $0) }
        )) {
            ForEach(Filter.allCases, id: \.self) { filter in
                Image(systemName: filter.systemImageName)
                    .resizable()
                    .tag(filter)
                    .accessibilityLabel(filter.name)
                    .frame(width: 50)
            }
            .frame(width: 50)
        }
        .pickerStyle(.segmented)
        .controlSize(.large)
        .tint(Color.LabelColors.labelPrimary)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 6)
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
