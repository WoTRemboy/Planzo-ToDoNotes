//
//  TaskListRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/13/25.
//

import SwiftUI

struct TaskListRow: View {
    
    private var name: String
    
    init(name: String) {
        self.name = name
    }
    
    internal var body: some View {
        Text(name)
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(Color.red)
    }
}

#Preview {
    TaskListRow(name: "Task name")
}
