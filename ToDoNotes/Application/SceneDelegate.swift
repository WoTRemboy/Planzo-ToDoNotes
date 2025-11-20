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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        guard url.scheme == "planzo", url.host == "open-list" else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let listId = components?.queryItems?.first(where: { $0.name == "listId" })?.value
        let code = components?.queryItems?.first(where: { $0.name == "code" })?.value
        if let listId = listId, let code = code {
            ListNetworkService.shared.openTaskFromDeepLink(listID: listId, code: code)
        }
    }
}
