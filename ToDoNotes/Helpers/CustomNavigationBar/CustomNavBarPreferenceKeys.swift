//
//  CustomNavBarPreferenceKeys.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/1/25.
//

import SwiftUI

struct CunstomNavBarTitlePreferenceKey: PreferenceKey {
    
    static var defaultValue: String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

struct CunstomNavBarBackButtonPreferenceKey: PreferenceKey {
    
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

extension View {
    private func customNavigationTitle(_ title: String) -> some View {
        preference(key: CunstomNavBarTitlePreferenceKey.self, value: title)
    }
    
    private func customNavigationBackButton(_ show: Bool) -> some View {
        preference(key: CunstomNavBarBackButtonPreferenceKey.self, value: show)
    }
    
    internal func customNavBarItems(title: String = String(), showBackButton: Bool = false) -> some View {
        self
            .customNavigationTitle(title)
            .customNavigationBackButton(showBackButton)
    }
}
