//
//  ColorComponentsFormatter.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 22/10/2025.
//

import SwiftUI

extension UIColor {
    internal var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    
    internal var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}
