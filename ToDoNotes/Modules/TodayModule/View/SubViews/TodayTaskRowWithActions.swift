//
//  TodayTaskRowWithActions.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/9/25.
//

import SwiftUI

struct TodayTaskRowWithSwipeActions: View {
    @EnvironmentObject private var viewModel: TodayViewModel
    
    @ObservedObject private var entity: TaskEntity
    private let isLast: Bool
    private let namespace: Namespace.ID
    
    init(entity: TaskEntity, isLast: Bool, namespace: Namespace.ID) {
        self._entity = ObservedObject(wrappedValue: entity)
        self.isLast = isLast
        self.namespace = namespace
    }
    
    internal var body: some View {
        Button {
            viewModel.selectedTask = entity
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        } label: {
            CustomContextMenu {
                TaskListRow(entity: entity, isLast: isLast)
                    .background(Color.SupportColors.supportListRow)
            } preview: {
                TaskManagementPreview(
                    entity: entity)
            } actions: {
                uiContextMenu
            } onEnd: {
                
            }
        }
//        .contextMenu { contextMenuContent }
        .swipeActions(edge: .leading, allowsFullSwipe: false) { leadingSwipeActions }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) { trailingSwipeActions }
    }
    
    private var uiContextMenu: UIMenu {
        let toggleImportantAction = UIAction(
            title: TaskService.taskCheckImportant(for: entity)
                ? Texts.TaskManagement.ContextMenu.importantDeselect
                : Texts.TaskManagement.ContextMenu.important,
            image: TaskService.taskCheckImportant(for: entity)
                ? UIImage(named: "importantDeselect")
                : UIImage(named: "important")
        ) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                try? TaskService.toggleImportant(for: entity)
            }
            Toast.shared.present(
                title: entity.important ? Texts.Toasts.importantOn : Texts.Toasts.importantOff)
        }
        
        let togglePinnedAction = UIAction(
            title: "Toggle Pinned",
            image: TaskService.taskCheckPinned(for: entity)
                ? UIImage(named: "pinnedDeselect")
                : UIImage(named: "pinned")
        ) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                try? TaskService.togglePinned(for: entity)
            }
            Toast.shared.present(
                title: entity.pinned ? Texts.Toasts.pinnedOn : Texts.Toasts.pinnedOff)
        }
        
        let removeAction = UIAction(
            title: "Remove Task",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                try? TaskService.toggleRemoved(for: entity)
            }
            Toast.shared.present(title: Texts.Toasts.removed)
        }
        
        return UIMenu(title: "", children: [toggleImportantAction, togglePinnedAction, removeAction])
    }
    
    private var contextMenuContent: some View {
        Group {
            ControlGroup {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        try? TaskService.toggleImportant(for: entity)
                    }
                    Toast.shared.present(
                        title: entity.important ?
                        Texts.Toasts.importantOn :
                            Texts.Toasts.importantOff)
                } label: {
                    Label {
                        TaskService.taskCheckImportant(for: entity) ?
                        Text(Texts.TaskManagement.ContextMenu.importantDeselect) :
                        Text(Texts.TaskManagement.ContextMenu.important)
                    } icon: {
                        TaskService.taskCheckImportant(for: entity) ?
                        Image.TaskManagement.EditTask.Menu.importantDeselect :
                        Image.TaskManagement.EditTask.Menu.importantSelect
                            .renderingMode(.template)
                    }
                }
                
                Button {
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
                
                Button(role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        try? TaskService.toggleRemoved(for: entity)
                    }
                    Toast.shared.present(
                        title: Texts.Toasts.removed)
                } label: {
                    Image.TaskManagement.TaskRow.SwipeAction.remove
                }
            }
            .controlGroupStyle(.compactMenu)
        }
    }
    
    private var leadingSwipeActions: some View {
        Group {
            Button(role: viewModel.importance ? .destructive : .cancel) {
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
    }
    
    private var trailingSwipeActions: some View {
        Group {
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
    TodayTaskRowWithSwipeActions(entity: PreviewData.taskItem,
                                 isLast: false,
                                 namespace: Namespace().wrappedValue)
    .environmentObject(TodayViewModel())
}
