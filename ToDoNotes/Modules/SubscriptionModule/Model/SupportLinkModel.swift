//
//  SupportLinkModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 18/09/2025.
//

enum SupportLink {
    case termsOfService
    case privacyPolicy
    
    internal var title: String {
        switch self {
        case .termsOfService:
            return "Terms of Service"
        case .privacyPolicy:
            return "Privacy Policy"
        }
    }
    
    internal var url: String {
        switch self {
        case .termsOfService:
            "https://avoqode.com/terms-of-service"
        case .privacyPolicy:
            "https://avoqode.com/privacy-policy"
        }
    }
}
