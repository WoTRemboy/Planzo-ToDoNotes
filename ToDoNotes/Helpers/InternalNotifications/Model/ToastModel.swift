//
//  ToastModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/8/25.
//

import SwiftUI

struct ToastItem: Identifiable {
    let id: UUID = .init()
    var title: String
    var symbol: Image?
    var tint: Color
    var isUserInteractionEnabled: Bool
    var timing: ToastTime = .medium
}

enum ToastTime: CGFloat {
    case short = 1.0
    case medium = 2.0
    case long = 3.5
}
