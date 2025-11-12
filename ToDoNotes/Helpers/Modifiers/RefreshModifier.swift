//
//  RefreshModifier.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 12/11/2025.
//

import SwiftUI

struct RefreshModifier: ViewModifier {
    
    @ObservedObject var authService: AuthNetworkService
    
    init(authService: AuthNetworkService) {
        self.authService = authService
    }
    
    func body(content: Content) -> some View {
        if authService.currentUser != nil {
            content
                .refreshable {
                    let lastSyncAt = authService.currentUser?.lastSyncAt
                    await FullSyncNetworkService.shared.refreshTasks(since: lastSyncAt)
                }
        } else {
            content
        }
    }
}
