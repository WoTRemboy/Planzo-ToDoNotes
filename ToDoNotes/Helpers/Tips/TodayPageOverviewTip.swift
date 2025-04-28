//
//  TodayPageOverviewTip.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 4/16/25.
//

import TipKit

/// A Tip for the Today page overview that provides users with a short explanation
/// about the Today page's purpose and functionality.
struct TodayPageOverview: Tip {
        
    /// The title of the tip, providing a brief headline describing the overview.
    internal var title: Text {
        Text(Texts.Tips.todayPageOverviewTitle)
    }
    
    /// An optional detailed message explaining more about the Today page.
    internal var message: Text? {
        Text(Texts.Tips.todayPageOverviewContent)
    }
}
