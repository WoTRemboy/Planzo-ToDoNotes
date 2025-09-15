//
//  SecretsManager.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 15/09/2025.
//

import Foundation

struct Secrets {
    private static func secrets() -> [String: Any] {
        let fileName = "Secrets"
        let path = Bundle.main.path(forResource: fileName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return try! JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    static var googleClientID: String {
        return secrets()["GOOGLE_CLIENT_ID"] as? String ?? String()
    }

    static var googleURLScheme: String {
        return secrets()["GOOGLE_URL_SCHEME"] as? String ?? String()
    }
}
