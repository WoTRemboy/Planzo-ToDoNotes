//
//  ReorderableDropOutsideDelegate.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 24/10/2025.
//

import SwiftUI

struct ReorderableDropOutsideDelegate<Item: Reorderable>: DropDelegate {
    
    @Binding
    var active: Item?
        
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        active = nil
        return true
    }
}
