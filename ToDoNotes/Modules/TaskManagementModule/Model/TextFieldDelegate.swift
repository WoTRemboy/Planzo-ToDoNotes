//
//  TextFieldDelegate.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//

import UIKit

/// A delegate class that handles the "Return" button press for a `UITextField`.
final class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    /// A closure that is called when the Return key is pressed.
    ///
    /// It should return `true` if the text field should process the return event, otherwise `false
    var shouldReturn: (() -> Bool)?
    
    /// Asks the delegate if the text field should process the pressing of the Return button.
    /// - Parameter textField: The text field whose return button was pressed.
    /// - Returns: A Boolean value indicating whether the text field should respond to the press.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let shouldReturn = shouldReturn {
            return shouldReturn()
        } else {
            return true
        }
    }
}
