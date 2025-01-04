//
//  ImageExtension.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI

extension Image {
    enum Placeholder {
        static let image = Image("PlaceholderImage")
    }
    
    enum NavigationBar {
        static let search = Image("SearchNavIcon")
        static let favorites = Image("FavoritesNavIcon")
    }
}
