//
//  AuthNetworkService.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 28/12/2025.
//

import Foundation

/// Centralized provider for API base URL that can be overridden via
/// - Environment variable: `API_BASE_URL(SHARE)` & `API_BASE_URL(SHARE)_DEBUG`
enum NetworkConfig {
    /// Raw base URL string, without a trailing slash.
    static var baseURLString: String {
        if let env = ProcessInfo.processInfo.environment["API_BASE_URL_DEBUG"], !env.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return env
        }
        
        if !Secrets.apiBaseURLDebug.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Secrets.apiBaseURLDebug
        }
        
        if let env = ProcessInfo.processInfo.environment["API_BASE_URL"], !env.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return env
        }
        
        if !Secrets.apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Secrets.apiBaseURL
        }
        
        return String()
    }
    
    /// Raw base URL string for share endpoints, without a trailing slash.
    static var baseURLShareString: String {
        if let env = ProcessInfo.processInfo.environment["API_BASE_URL_SHARE_DEBUG"], !env.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return env
        }
        
        if !Secrets.apiBaseURLShareDebug.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Secrets.apiBaseURLShareDebug
        }
        
        if let env = ProcessInfo.processInfo.environment["API_BASE_URL_SHARE"], !env.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return env
        }
        
        if !Secrets.apiBaseURLShare.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Secrets.apiBaseURLShare
        }
        
        return String()
    }

    /// Normalized base URL (ensures scheme and no trailing slash)
    private static var normalizedBase: String {
        let trimmed = baseURLString.trimmingCharacters(in: CharacterSet(charactersIn: "/ "))
        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            return trimmed
        } else {
            return "https://\(trimmed)"
        }
    }

    /// Builds a full URL by appending a path to the base URL.
    /// - Parameter path: can start with or without leading slash
    static func url(_ path: String) -> URL? {
        let pathClean = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return URL(string: "\(normalizedBase)/\(pathClean)")
    }
}

