//
//  TaskChecklistView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import SwiftUI
import SwiftUIIntrospect

struct TaskChecklistView: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    @FocusState private var focusedItemID: UUID?
    
    private var textFieldDelegates: [UUID: TextFieldDelegate]
    
    init(viewModel: TaskManagementViewModel) {
        self.viewModel = viewModel
        
        self.textFieldDelegates = Dictionary(uniqueKeysWithValues: viewModel.checklistLocal.map {
            ($0.id, TextFieldDelegate())
        })
    }
    
    internal var body: some View {
        VStack(spacing: 8) {
            ForEach($viewModel.checklistLocal) { $item in
                HStack {
                    Button(action: {
                        withAnimation {
                            item.completed.toggle()
                        }
                    }) {
                        (item.completed ?
                         Image.TaskManagement.EditTask.checkListCheck :
                         Image.TaskManagement.EditTask.checkListUncheck)
                        .frame(width: 15, height: 15)
                    }
                    
                    TextField(Texts.TaskManagement.point,
                              text: $item.name)
                        .focused($focusedItemID, equals: item.id)
                        .introspect(.textField, on: .iOS(.v16, .v17, .v18)) { textField in
                            setupDelegate(for: textField, itemID: item.id)
                        }
                        
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskChecklistView(viewModel: TaskManagementViewModel())
}


extension TaskChecklistView {
    
    // MARK: - Delegate setup
    
    private func setupDelegate(for textField: UITextField, itemID: UUID) {
        guard let delegate = textFieldDelegates[itemID] else { return }
        
        delegate.shouldReturn = {
            self.viewModel.addChecklistItem(after: itemID)
            self.focusOnNextItem(after: itemID)
            return false
        }
        
        textField.delegate = delegate
    }
    
    // MARK: - Focus menagement
    
    private func focusOnNextItem(after id: UUID) {
        if let currentIndex = viewModel.checklistLocal.firstIndex(where: { $0.id == id }),
           currentIndex < viewModel.checklistLocal.count - 1 {
            focusedItemID = viewModel.checklistLocal[currentIndex + 1].id
        }
    }
}
