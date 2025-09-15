//
//  LoginButtonView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 12/09/2025.
//

import SwiftUI

enum LoginButton {
    case apple
    case google
    
    internal var image: Image {
        switch self {
        case .apple:
            Image.LoginPage.appleLogo
        case .google:
            Image.LoginPage.googleLogo
        }
    }
    
    internal var title: String {
        switch self {
        case .apple:
            Texts.Authorization.appleLogin
        case .google:
            Texts.Authorization.googleLogin
        }
    }
}

struct LoginButtonView: View {
    
    private let type: LoginButton
    private let action: () -> Void
    
    init(type: LoginButton, action: @escaping () -> Void) {
        self.type = type
        self.action = action
    }
    
    internal var body: some View {
        Button {
            action()
        } label: {
            HStack {
                type.image
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text(type.title)
                    .font(.system(size: 17, weight: .medium))
                    .minimumScaleFactor(0.4)
                    .foregroundStyle(Color.LabelColors.labelReversed)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.ButtonColors.login)
        }
        .clipShape(.rect(cornerRadius: 12))
        .frame(height: 50)
    }
}

#Preview {
    LoginButtonView(type: .apple) {}
}
