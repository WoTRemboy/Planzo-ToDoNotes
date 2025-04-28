//
//  MainPageOverviewTip.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 4/16/25.
//

import TipKit

/// A Tip for the Main page overview that provides users with a short explanation
/// about the Main page's purpose and functionality.
struct MainPageOverview: Tip {
    
    /// The title text displayed for the main page overview tip.
    internal var title: Text {
        Text(Texts.Tips.mainPageOverviewTitle)
    }
    
    /// An optional detailed message explaining more about the Main page.
    internal var message: Text? {
        Text(Texts.Tips.mainPageOverviewContent)
    }
}
