//
//  ToDoNotesApp.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI
import GoogleSignIn

@main
struct ToDoNotesApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(CoreDataViewModel())
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
