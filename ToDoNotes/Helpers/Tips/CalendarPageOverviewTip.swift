//
//  CalendarPageOverviewTip.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 4/16/25.
//

import TipKit

struct CalendarPageOverview: Tip {
    internal var title: Text {
        Text(Texts.Tips.calendarPageOverviewTitle)
    }
    
    internal var message: Text? {
        Text(Texts.Tips.calendarPageOverviewContent)
    }
}
