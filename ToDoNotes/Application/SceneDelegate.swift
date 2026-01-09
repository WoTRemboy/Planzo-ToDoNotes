//
//  SceneDelegate.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 10/11/2025.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private var isReadyForDeepLinks = false
    private var pendingDeepLinkURL: URL?
    
    private func handle(url: URL) {
        guard url.scheme == "planzo", url.host == "open-list" else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let listId = components?.queryItems?.first(where: { $0.name == "listId" })?.value
        let code = components?.queryItems?.first(where: { $0.name == "code" })?.value
        if let listId = listId, let code = code {
            ListNetworkService.shared.openTaskFromDeepLink(listID: listId, code: code)
        }
    }
    
    private func route(url: URL) {
        if isReadyForDeepLinks {
            handle(url: url)
        } else {
            pendingDeepLinkURL = url
        }
    }
    
    @objc private func handleAppReadyForDeepLinks() {
        isReadyForDeepLinks = true
        if let url = pendingDeepLinkURL {
            pendingDeepLinkURL = nil
            handle(url: url)
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppReadyForDeepLinks), name: .appDidBecomeReadyForDeepLinks, object: nil)
        
        if let url = connectionOptions.urlContexts.first?.url {
            route(url: url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        route(url: url)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        NotificationCenter.default.removeObserver(self, name: .appDidBecomeReadyForDeepLinks, object: nil)
    }
}

extension Notification.Name {
    static let appDidBecomeReadyForDeepLinks = Notification.Name("AppDidBecomeReadyForDeepLinks")
}
