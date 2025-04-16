//
//  TodayPageOverviewTip.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 4/16/25.
//

import TipKit

struct TodayPageOverview: Tip {
    internal var title: Text {
        Text(Texts.Tips.todayPageOverviewTitle)
    }
    
    internal var message: Text? {
        Text(Texts.Tips.todayPageOverviewContent)
    }
}
