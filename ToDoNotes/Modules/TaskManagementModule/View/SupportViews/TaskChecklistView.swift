//
//  TaskChecklistView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import SwiftUI
import UniformTypeIdentifiers

/// A view that displays and manages the checklist for a task.
struct TaskChecklistView: View {
    
    // MARK: - Properties
    
    /// The view model managing the checklist state.
    @ObservedObject private var viewModel: TaskManagementViewModel
    /// ID of the currently focused checklist item.
    @FocusState private var focusedItemID: UUID?
    
    /// Whether the checklist is shown in preview mode (read-only).
    private let preview: Bool
    
    // MARK: - Initialization
    
    /// Initializes the checklist view with a view model and preview mode option.
    /// - Parameters:
    ///   - viewModel: The view model managing the checklist.
    ///   - preview: Whether the view is displayed in preview mode (default is `false`).
    init(viewModel: TaskManagementViewModel, preview: Bool = false) {
        self.viewModel = viewModel
        self.preview = preview
    }
    
    // MARK: - Body
    
    /// Builds the checklist layout using a vertical lazy grid.
    internal var body: some View {
        LazyVStack(spacing: 0) {
            ForEach($viewModel.checklistLocal) { $item in
                draggableRow(for: $item)
                    .id(item.id)
            }
        }
        .padding(.vertical, 4)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isChecklistReordering)
        .onChange(of: viewModel.lastInsertedChecklistID) { _, newID in
            guard !preview, viewModel.accessToEdit, let newID else { return }
            if viewModel.checklistLocal.contains(where: { $0.id == newID }) {
                DispatchQueue.main.async {
                    focusedItemID = newID
                }
            }
        }
        .onChange(of: viewModel.isChecklistReordering) { _, isActive in
            if isActive {
                focusedItemID = nil
            } else {
                viewModel.finalizeChecklistDragState()
            }
        }
        .onChange(of: viewModel.draggingItemID) { _, newValue in
            if newValue == nil, viewModel.draggingItem != nil || viewModel.dropTargetItemID != nil {
                viewModel.clearChecklistDragState()
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func rowContent(for item: Binding<ChecklistItem>) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if viewModel.isChecklistReordering {
                reorderIndicator
                reorderTitle(for: item.wrappedValue)
            } else {
                checkbox(item: item)
                textField(item: item)
                
                if !preview, viewModel.accessToEdit {
                    removeButton(item: item)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
        }
    }

    @ViewBuilder
    private func draggableRow(for item: Binding<ChecklistItem>) -> some View {
        let currentItem = item.wrappedValue
        let baseRow = rowContent(for: item)
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowBackground(for: currentItem))
            .contentShape(Rectangle())

        if viewModel.isChecklistReordering {
            let draggableRow = baseRow
                .onDrop(
                    of: [UTType.plainText],
                    delegate: ChecklistDropDelegate(
                        targetItem: currentItem,
                        checklistLocal: $viewModel.checklistLocal,
                        draggingItem: $viewModel.draggingItem,
                        draggingItemID: $viewModel.draggingItemID,
                        dropTargetItemID: $viewModel.dropTargetItemID,
                        isChecklistDragActive: $viewModel.isChecklistDragActive,
                        isChecklistDragFinishing: $viewModel.isChecklistDragFinishing
                    )
                )
                .onDrag {
                    viewModel.setDraggingItem(for: currentItem)
                    return NSItemProvider(object: currentItem.id.uuidString as NSString)
                } preview: {
                    dragPreview(for: currentItem)
                        .onAppear {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }
                }

            draggableRow
        } else {
            baseRow
        }
    }

    private func reorderTitle(for item: ChecklistItem) -> some View {
        Text(item.name.isEmpty ? Texts.TaskManagement.point : item.name)
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(item.completed ? Color.LabelColors.labelDetails : Color.LabelColors.labelPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 1)
    }

    /// Checkbox to mark item as completed or not.
    private func checkbox(item: Binding<ChecklistItem>) -> some View {
        Button {
            if !item.wrappedValue.name.isEmpty {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleChecklistComplete(for: item)
                }
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        } label: {
            (item.wrappedValue.completed ? checkedBox : uncheckedBox)
                .foregroundStyle(
                    (item.wrappedValue.completed || item.wrappedValue.name.isEmpty) ? Color.LabelColors.labelDetails : Color.LabelColors.labelPrimary)
            
                .frame(width: 18, height: 18)
        }
        .disabled(preview || !viewModel.accessToEdit || viewModel.isChecklistReordering)
        .onAppear {
            if !item.wrappedValue.name.isEmpty, viewModel.check == .checked {
                item.wrappedValue.completed = true
            }
        }
    }
    
    /// Editable text field for checklist item.
    private func textField(item: Binding<ChecklistItem>) -> some View {
        TextField(Texts.TaskManagement.point,
                  text: item.name,
                  axis: .vertical)
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(
            item.wrappedValue.completed ? Color.LabelColors.labelDetails : Color.LabelColors.labelPrimary)
        
        .disabled(preview || !viewModel.accessToEdit || viewModel.isChecklistReordering)
        .focused($focusedItemID, equals: item.id)
        .contentShape(.rect)
        .padding(.vertical, 1)
    }

    private var reorderIndicator: some View {
        Image.TaskManagement.EditTask.Checklist.move
            .frame(width: 18, height: 18)
            .padding(.top, 2)
            .phaseAnimator([false, true]) { content, phase in
                content
                    .rotationEffect(.degrees(phase ? 0.8 : -0.8))
                    .offset(x: phase ? 0.3 : -0.3, y: phase ? -0.15 : 0.15)
            } animation: { _ in
                .easeInOut(duration: 0.24)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    @ViewBuilder
    private func rowBackground(for item: ChecklistItem) -> some View {
        let hasActiveDrag = !viewModel.isChecklistDragFinishing && viewModel.isChecklistDragActive && viewModel.highlightedChecklistItemID != nil
        let isDragging = !viewModel.isChecklistDragFinishing && viewModel.isChecklistDragActive && viewModel.highlightedChecklistItemID == item.id
        let isDropTarget = hasActiveDrag && viewModel.dropTargetItemID == item.id
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(isDragging ? Color.BackColors.backSecondary : .clear)
            .shadow(color: .black.opacity(isDragging ? 0.08 : 0), radius: 8, x: 0, y: 4)
            .scaleEffect(isDragging ? 1.01 : 1)
            .animation(.easeInOut(duration: 0.18), value: isDragging)
            .animation(.easeInOut(duration: 0.12), value: isDropTarget)
    }
    
    /// Button to remove the checklist item.
    private func removeButton(item: Binding<ChecklistItem>) -> some View {
        Button {
            let removingID = item.wrappedValue.id
            let isFocused = (focusedItemID == removingID)
            var previousID: UUID?
            if let idx = viewModel.checklistLocal.firstIndex(where: { $0.id == removingID }), idx > 0 {
                previousID = viewModel.checklistLocal[idx - 1].id
            }
            if isFocused {
                if let prev = previousID {
                    focusedItemID = prev
                } else {
                    DispatchQueue.main.async {
                        focusedItemID = nil
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.bouncy(duration: 0.2)) {
                    viewModel.removeChecklistItem(item.wrappedValue)
                }
            }
        } label: {
            Rectangle()
                .foregroundStyle(Color.BackColors.backDefault)
                .frame(width: 20, height: 20)
                .overlay {
                    Image.TaskManagement.EditTask.Checklist.remove
                        .resizable()
                        .frame(width: 15, height: 15)
                }
        }
    }
    
    private func dragPreview(for item: ChecklistItem) -> some View {
        Text(item.name.isEmpty ? Texts.TaskManagement.point : item.name)
            .font(.system(size: 17, weight: .regular))
            .lineLimit(1)
            .padding(10)
            .background(Color.BackColors.backSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Icons
    
    /// Icon for unchecked checklist item.
    private var uncheckedBox: Image {
        Image.TaskManagement.EditTask.Checklist.uncheck
            .renderingMode(.template)
    }
    
    /// Icon for checked checklist item.
    private var checkedBox: Image {
        Image.TaskManagement.EditTask.Checklist.check
    }
}

// MARK: - Preview

#Preview {
    TaskChecklistView(viewModel: TaskManagementViewModel())
}

// MARK: - Extensions

extension TaskChecklistView {
    
    // MARK: - Focus menagement
    
    /// Focuses on the next checklist item after the given ID.
    /// - Parameter id: The UUID of the current checklist item.
    private func focusOnNextItem(after id: UUID) {
        if let currentIndex = viewModel.checklistLocal.firstIndex(where: { $0.id == id }),
           currentIndex < viewModel.checklistLocal.count - 1 {
            focusedItemID = viewModel.checklistLocal[currentIndex + 1].id
        }
    }
    
    /// Focuses on the previous checklist item before the given ID.
    /// - Parameter id: The UUID of the current checklist item.
    private func focusOnPreviousItem(before id: UUID) {
        if let currentIndex = viewModel.checklistLocal.firstIndex(where: { $0.id == id }),
           currentIndex > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
                focusedItemID = viewModel.checklistLocal[currentIndex - 1].id
            }
        } else {
            if let firstIndex = viewModel.checklistLocal.first?.id {
                focusedItemID = firstIndex
            }
        }
    }
}

private struct ChecklistDropDelegate: DropDelegate {
    let targetItem: ChecklistItem
    @Binding var checklistLocal: [ChecklistItem]
    @Binding var draggingItem: ChecklistItem?
    @Binding var draggingItemID: UUID?
    @Binding var dropTargetItemID: UUID?
    @Binding var isChecklistDragActive: Bool
    @Binding var isChecklistDragFinishing: Bool

    func dropEntered(info: DropInfo) {
        guard let draggingItemID, draggingItemID != targetItem.id else { return }
        dropTargetItemID = targetItem.id
        guard let fromIndex = checklistLocal.firstIndex(where: { $0.id == draggingItemID }),
              let toIndex = checklistLocal.firstIndex(where: { $0.id == targetItem.id }) else { return }
        guard fromIndex != toIndex else { return }

        withAnimation(.easeInOut(duration: 0.18)) {
            checklistLocal.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
            normalizeChecklistOrder()
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        isChecklistDragFinishing = true
        isChecklistDragActive = false
        draggingItem = nil
        draggingItemID = nil
        dropTargetItemID = nil
        normalizeChecklistOrder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            isChecklistDragFinishing = false
            isChecklistDragActive = false
            draggingItem = nil
            draggingItemID = nil
            dropTargetItemID = nil
        }
        return true
    }

    private func normalizeChecklistOrder() {
        for index in checklistLocal.indices {
            checklistLocal[index].order = index
        }
    }
}
