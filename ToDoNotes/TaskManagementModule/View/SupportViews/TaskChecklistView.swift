//
//  TaskChecklistView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import SwiftUI

struct TaskChecklistView: View {
    
    @EnvironmentObject private var viewModel: CoreDataViewModel
    @FocusState private var newItemFocused: Bool

    internal var body: some View {
        checkPoints
    }
    
    private var checkPoints: some View {
        VStack(spacing: 8) {
            ForEach($viewModel.checklistItems) { $item in
                HStack {
                    Button(action: {
                        withAnimation {
                            item.isChecked.toggle()
                        }
                    }) {
                        (item.isChecked ?
                        Image.TaskManagement.EditTask.checkListCheck :
                        Image.TaskManagement.EditTask.checkListUncheck)
                        .frame(width: 15, height: 15)
                    }
                    
                    TextField(String(), text: $item.title)
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
                        viewModel.addItem()
                    }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskChecklistView()
}
