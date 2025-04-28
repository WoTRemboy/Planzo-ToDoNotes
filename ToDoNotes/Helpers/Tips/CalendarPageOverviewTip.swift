//
//  CalendarPageOverviewTip.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 4/16/25.
//

import TipKit

/// A Tip for the Calendar page overview that provides users with a short explanation
/// about the Calendar page's purpose and functionality.
struct CalendarPageOverview: Tip {
        
    /// The title of the tip, providing a brief headline describing the overview.
    internal var title: Text {
        Text(Texts.Tips.calendarPageOverviewTitle)
    }
        
    /// An optional detailed message explaining more about the Calendar page.
    internal var message: Text? {
        Text(Texts.Tips.calendarPageOverviewContent)
    }
}
