//
//  TextFieldDelegate.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import UIKit

final class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    var shouldReturn: (() -> Bool)?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let shouldReturn = shouldReturn {
            return shouldReturn()
        }
        else {
            return true
        }
    }
}
