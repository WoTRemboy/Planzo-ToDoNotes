//
//  MainPageOverviewTip.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 4/16/25.
//

import TipKit

struct MainPageOverview: Tip {
    internal var title: Text {
        Text(Texts.Tips.mainPageOverviewTitle)
    }
    
    internal var message: Text? {
        Text(Texts.Tips.mainPageOverviewContent)
    }
}
