//
//  Test.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/15/25.
//


import SwiftUIIntrospect
import UIKit
import SwiftUI

struct TestView: View {
    
    enum FocusedField {
        case username, password
    }
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    var usernameFieldDelegate = TextFieldDelegate()
    var passwordFieldDelegate = TextFieldDelegate()
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        
        VStack {
            TextField("fdnsjfds", text: $username)
                .focused($focusedField, equals: .username)
                .introspect(.textField, on: .iOS(.v16, .v17, .v18)) { textField in
                    
                    usernameFieldDelegate.shouldReturn = {
                        
                        if usernameIsValid() {
                            focusedField = .password
                        }
                        
                        return false
                    }
                    
                    textField.delegate = usernameFieldDelegate
                }
            
            
            
            TextField("fdsjkfnds", text: $password)
                .focused($focusedField, equals: .password)
                .introspect(.textField, on: .iOS(.v16, .v17, .v18)) { textField in
                    
                    passwordFieldDelegate.shouldReturn = {
                        validateAndProceed()
                        
                        return false
                    }
                    
                    textField.delegate = passwordFieldDelegate
                }
        }
    }
    
    func usernameIsValid() -> Bool {
        return true
    }
    
    func validateAndProceed() {}
}

#Preview {
    TestView()
}
