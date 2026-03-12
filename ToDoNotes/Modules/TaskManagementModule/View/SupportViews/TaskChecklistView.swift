//
//  TaskChecklistView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import SwiftUI

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
                HStack(alignment: .top) {
                    checkbox(item: $item)
                    textField(item: $item)
                    
                    if !preview, viewModel.accessToEdit {
                        removeButton(item: $item)
                        dragHandle(for: $item)
                    }
                }
                .padding(.vertical, 3)
                .padding(.horizontal, 8)
                
                // Handle drag and drop
                .dropDestination(for: ChecklistItem.self) { item, location in
                    viewModel.setDraggingItem(for: nil)
                    return false
                } isTargeted: { status in
                    viewModel.setDraggingTargetResult(for: item, status: status)
                }
                .id(item.id)
            }
        }
        .padding(.vertical, 4)
        .onChange(of: viewModel.lastInsertedChecklistID) { _, newID in
            guard !preview, viewModel.accessToEdit, let newID else { return }
            if viewModel.checklistLocal.contains(where: { $0.id == newID }) {
                DispatchQueue.main.async {
                    focusedItemID = newID
                }
            }
        }
    }
    
    // MARK: - Components
    
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
        .disabled(preview || !viewModel.accessToEdit)
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
        
        .disabled(preview || !viewModel.accessToEdit)
        .focused($focusedItemID, equals: item.id)
        .contentShape(.rect)
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
    
    /// Drag handle to reorder checklist items.
    private func dragHandle(for item: Binding<ChecklistItem>) -> some View {
        Image.TaskManagement.EditTask.Checklist.move
            .contentShape(Rectangle())
            .draggable(item.wrappedValue) {
                Color.clear
                    .frame(width: 1, height: 1)
                    .onAppear {
                        viewModel.setDraggingItem(for: item.wrappedValue)
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }
            }
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

