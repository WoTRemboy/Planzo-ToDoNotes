//
//  TokenStorageService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 08/09/2025.
//

import Foundation
import Security

final class TokenStorageService {
    enum TokenType: String {
        case appleIDToken
        case googleIDToken
        case accessToken
        case refreshToken
    }
    
    /// Saves a token in the Keychain
    @discardableResult
    func save(token: String, type: TokenType) -> Bool {
        let key = type.rawValue
        
        // Remove the old value if it exists
        delete(type: type)
        guard let data = token.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    /// Loads a token from the Keychain
    func load(type: TokenType) -> String? {
        let key = type.rawValue
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &dataTypeRef) == noErr,
           let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    /// Deletes a token from the Keychain
    @discardableResult
    func delete(type: TokenType) -> Bool {
        let key = type.rawValue
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
    
    /// Clears all tokens (all supported types)
    func clearAll() {
        for type in [TokenType.appleIDToken, .googleIDToken, .accessToken, .refreshToken] {
            _ = delete(type: type)
        }
    }
}
