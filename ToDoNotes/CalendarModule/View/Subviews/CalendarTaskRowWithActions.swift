//
//  CalendarTaskRowWithActions.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/9/25.
//

import SwiftUI

struct CalendarTaskRowWithActions: View {
    @EnvironmentObject private var viewModel: CalendarViewModel
    
    @ObservedObject private var entity: TaskEntity
    private let isLast: Bool
    
    init(entity: TaskEntity, isLast: Bool) {
        self._entity = ObservedObject(wrappedValue: entity)
        self.isLast = isLast
    }
    
    internal var body: some View {
        Button {
            viewModel.selectedTask = entity
        } label: {
            TaskListRow(entity: entity, isLast: isLast)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(role: .cancel) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    try? TaskService.toggleImportant(for: entity)
                }
                Toast.shared.present(
                    title: entity.important ?
                        Texts.Toasts.importantOn :
                        Texts.Toasts.importantOff)
            } label: {
                TaskService.taskCheckImportant(for: entity) ?
                    Image.TaskManagement.TaskRow.SwipeAction.importantDeselect :
                    Image.TaskManagement.TaskRow.SwipeAction.important
            }
            .tint(Color.SwipeColors.important)
            
            Button(role: .destructive) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    try? TaskService.togglePinned(for: entity)
                }
                Toast.shared.present(
                    title: entity.pinned ?
                        Texts.Toasts.pinnedOn :
                        Texts.Toasts.pinnedOff)
            } label: {
                TaskService.taskCheckPinned(for: entity) ?
                    Image.TaskManagement.TaskRow.SwipeAction.pinnedDeselect :
                    Image.TaskManagement.TaskRow.SwipeAction.pinned
            }
            .tint(Color.SwipeColors.pin)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    try? TaskService.toggleRemoved(for: entity)
                }
                Toast.shared.present(
                    title: Texts.Toasts.removed)
            } label: {
                Image.TaskManagement.TaskRow.SwipeAction.remove
            }
            .tint(Color.SwipeColors.remove)
        }
    }
}

#Preview {
    CalendarTaskRowWithActions(entity: PreviewData.taskItem, isLast: false)
}
