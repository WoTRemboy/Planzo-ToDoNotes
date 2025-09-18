//
//  TaskChecklistView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import SwiftUI
import SwiftUIIntrospect

/// A view that displays and manages the checklist for a task.
struct TaskChecklistView: View {
    
    // MARK: - Properties
    
    /// The view model managing the checklist state.
    @ObservedObject private var viewModel: TaskManagementViewModel
    /// ID of the currently focused checklist item.
    @FocusState private var focusedItemID: UUID?
    
    /// Mapping of each checklist item ID to its text field delegate.
    private var textFieldDelegates: [UUID: TextFieldDelegate]
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
        
        self.textFieldDelegates = Dictionary(uniqueKeysWithValues: viewModel.checklistLocal.map {
            ($0.id, TextFieldDelegate())
        })
    }
    
    // MARK: - Body
    
    /// Builds the checklist layout using a vertical lazy grid.
    internal var body: some View {
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: 6),
            count: 1)
        
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach($viewModel.checklistLocal) { $item in
                HStack {
                    checkbox(item: $item)
                    textField(item: $item)
                    
                    if !preview {
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
                // Handle deletion on empty input
                .onChange(of: item.name) { _, newValue in
                    if newValue == String() {
                        focusOnPreviousItem(before: item.id)
                        withAnimation(.linear(duration: 0.2)) {
                            viewModel.removeChecklistItem(for: item.id)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
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
                .animation(.easeInOut(duration: 0.2), value: item.wrappedValue.name)
        }
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
                  axis: preview ? .vertical : .horizontal)
        .font(.system(size: 17, weight: .regular))
        .foregroundStyle(
            item.wrappedValue.completed ? Color.LabelColors.labelDetails : Color.LabelColors.labelPrimary)
        
        .submitLabel(.next)
        .focused($focusedItemID, equals: item.id)
        .introspect(.textField, on: .iOS(.v16, .v17, .v18, .v26)) { textField in
            setupDelegate(for: textField, itemID: item.id)
        }
    }
    
    /// Button to remove the checklist item.
    private func removeButton(item: Binding<ChecklistItem>) -> some View {
        Button {
            withAnimation(.bouncy(duration: 0.2)) {
                viewModel.removeChecklistItem(item.wrappedValue)
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
    
    // MARK: - Delegate setup
    
    /// Sets up a delegate for a text field to manage keyboard return key behavior.
    /// - Parameters:
    ///   - textField: The `UITextField` instance.
    ///   - itemID: The ID of the checklist item associated with the text field.
    private func setupDelegate(for textField: UITextField, itemID: UUID) {
        guard let delegate = textFieldDelegates[itemID] else { return }
        
        delegate.shouldReturn = {
            if let text = textField.text, text.isEmpty {
                self.focusOnPreviousItem(before: itemID)
                withAnimation(.linear(duration: 0.2)) {
                    self.viewModel.removeChecklistItem(for: itemID)
                }
            } else {
                self.viewModel.addChecklistItem(after: itemID)
                self.focusOnNextItem(after: itemID)
            }
            return false
        }
        
        textField.delegate = delegate
    }
    
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
