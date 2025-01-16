//
//  TaskChecklistView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import SwiftUI

struct TaskChecklistView: View {
    
    @ObservedObject private var viewModel: TaskManagementViewModel
    @FocusState private var newItemFocused: Bool
    
    init(viewModel: TaskManagementViewModel) {
        self.viewModel = viewModel
    }

    internal var body: some View {
        checkPoints
    }
    
    private var checkPoints: some View {
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
                    
                    TextField(String(), text: $item.name)
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused($newItemFocused, equals: item.id == viewModel.lastAddedItemID)
                        .onAppear {
                            if item.id == viewModel.lastAddedItemID {
                                DispatchQueue.main.async {
                                    newItemFocused = true
                                }
                            }
                        }
                }
            }
            
            HStack {
                Image.TaskManagement.EditTask.checkListUncheck
                    .frame(width: 15, height: 15)
                
                TextField("Пункт \(viewModel.checklistItems.count + 1)",
                          text: $viewModel.newItemText)
                    .focused($newItemFocused)
                    .onSubmit {
                        viewModel.addChecklistItem()
                    }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskChecklistView(viewModel: TaskManagementViewModel())
}
