//
//  CalendarViewIPad.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/18/25.
//

import SwiftUI

struct CalendarViewIPad: View {
    @EnvironmentObject private var viewModel: CalendarViewModel
    @Namespace private var animation

    private let splitRatioLandscape: CGFloat = 1.0 / 3.0
    private let splitRatioPortrait: CGFloat = 0.45

    internal var body: some View {
        GeometryReader { proxy in
            let isPortrait = proxy.size.height >= proxy.size.width
            let splitRatio = isPortrait ? splitRatioPortrait : splitRatioLandscape
            let leftWidth = proxy.size.width * splitRatio
            let rightWidth = proxy.size.width - leftWidth

            HStack(spacing: 0) {
                CalendarView(showsSelectedTaskCover: false)
                    .frame(width: leftWidth)

                Divider()

                taskDetailPane
                    .frame(width: rightWidth)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var taskDetailPane: some View {
        if let task = viewModel.selectedTask {
            TaskManagementView(
                taskManagementHeight: .constant(0),
                entity: task,
                namespace: animation
            ) {
                viewModel.toggleShowingTaskEditView()
            }
        } else {
            emptyTaskPlaceholder
        }
    }

    private var emptyTaskPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 36, weight: .semibold))
            Text(Texts.Placeholders.selectTask)
                .font(.system(size: 18, weight: .semibold))
        }
        .foregroundStyle(Color.LabelColors.labelSecondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.BackColors.backDefault)
    }
}

#Preview {
    CalendarViewIPad()
        .environmentObject(CalendarViewModel())
        .environmentObject(AuthNetworkService())
}
